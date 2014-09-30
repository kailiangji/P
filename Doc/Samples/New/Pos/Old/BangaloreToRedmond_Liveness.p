event BookCab assume 2;
event BookFlight assert 2;
event FlightBooked assert 2;
event TryAgain assert 2;
event CabBooked assume 1; 
event Thanks assume 1; 
event ReachedAirport assert 2; 
event MissedFlight assert 2; 
event TookFlight assert 2; 
event Unit assert 2;

main machine Employee {
    var TravelAgentId: model;
    var CityCabId: model;
    var Check: bool;
    var RemoteCheckIn: bool;

    start state Init {
		defer CabBooked;
        entry {
            TravelAgentId = new TravelAgent(this); 
            CityCabId = new CityCab(this);
            RemoteCheckIn = false;
            raise Unit;
        }
            on Unit goto BangaloreOffice;
        }

    state BangaloreOffice {
	defer CabBooked;
        entry {
           push SBookFlight;
        }
        exit {
            if (trigger == FlightBooked) send TravelAgentId, Thanks;
        }
        on TryAgain goto BangaloreOffice;
        on FlightBooked goto SBookCab;
    }

    state SBookFlight { 
		defer CabBooked;
        entry {
            send TravelAgentId, BookFlight; 
            return; 
        }
    }

    state SBookCab { 
		
        entry { 
            send CityCabId, BookCab; 
        }
        exit { 
            assert(RemoteCheckIn == false); 
            RemoteCheckIn = true; 
            if (trigger != null) send CityCabId, Thanks;
        }
		on CabBooked goto TakeCab;
        on default goto TakeBus;
    }

    state TakeCab {
        entry { 
            raise ReachedAirport; 
        }
        on ReachedAirport goto AtAirport;
    }

    state TakeBus {
        entry { 
            raise ReachedAirport; 
        }
        on ReachedAirport goto AtAirport;
    }

    state AtAirport{
        entry {
            assert(RemoteCheckIn == true);
            Check = AmILucky();
            if (Check) {
                raise TookFlight;
            } else {
                raise MissedFlight;
            }
        }

        exit {
            RemoteCheckIn = false;
        }

        on TookFlight goto ReachedRedmond;
        on MissedFlight goto BangaloreOffice;
    }

    state ReachedRedmond {
        entry { raise Unit; }
		on Unit goto BangaloreOffice;
    }

    model fun AmILucky():bool { 
        if ($) 
            return true;
        else
            return false;
    }
}

model TravelAgent {
    var EmployeeId: machine;
    start state Init {
        entry {
	      EmployeeId = payload as machine;
	      raise Unit;
        }
        on Unit goto WaitToBook;
    }

    state WaitToBook { 
        on BookFlight goto SBookFlight;
    }

    state SBookFlight {
        entry { 
            if ($) { send EmployeeId, TryAgain; raise Unit; } else { send EmployeeId, FlightBooked; } 
        }
        on Unit goto WaitToBook;
        on Thanks goto WaitToBook;
    }
}

model CityCab {
    var EmployeeId: machine;

    start state Init {
	entry {
			   EmployeeId = payload as machine;
			   raise Unit;
	}
        on Unit goto WaitToBook;
    }

    state WaitToBook { 
		ignore Thanks;
        on BookCab goto SBookCab;
    }

    state SBookCab {
        entry { 
            if ($) { raise Unit;} else { send EmployeeId, CabBooked; }
        } 
        on Unit goto WaitToBook;
        on Thanks goto WaitToBook;
		on BookCab goto SBookCab;
    }
}
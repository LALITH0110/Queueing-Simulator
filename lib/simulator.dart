import 'package:yaml/yaml.dart';
import 'processes.dart';
import 'util/stats.dart';

/// Queueing system simulator.
class Simulator {
  final bool verbose;
  final List<Event> events = []; 
  double totalWait = 0.0;


  Simulator(YamlMap yamlData, {this.verbose = false}) {
    if (verbose) {
      print('\n[DEBUG] Initializing simulator');
    }
    for (final name in yamlData.keys) {
      final fields = yamlData[name];
      int arrivalTime = 0;
      int duration = 0;
      String type = fields['type'];
      // replace print statements with process creation
//------------------------------------------------------------------------------------------
      switch (fields['type']) {                     
        case 'singleton':                                                            //declaring variables assosiating with their fields
          arrivalTime = fields['arrival'];
          duration = fields['duration'];
          print('singleton with duration=${fields['duration']}');
          events.add(Event(name, arrivalTime, duration));                            //adding the event to the list
          
          print('$name: whose type is $type arrives $arrivalTime, lasts $duration'); //printing the contents of the event
          break;
//------------------------------------------------------------------------------------------
        case 'periodic':
          duration = fields['duration'];
          print('periodic with ${fields['num-repetitions']} events');
          for (int i=0; i<fields['num-repetitions']; i++) {                             //for every event(since every event is same)
            int arrival = fields['first-arrival'] + i * fields['interarrival-time'];    //arrival for every event each
            events.add(Event(name, arrival, duration));                                 //adds events
          }
          break;
          
//------------------------------------------------------------------------------------------
        case 'stochastic':
          print('stochastic with mean duration=${fields['mean-duration']}');
          final meanDur = (fields['mean-duration'] as num).toDouble();                //just getting the values from the sim.yaml
          final meanIntTime = (fields['mean-interarrival-time'] as num).toDouble();  //making it double
          final firstArrival = fields['first-arrival'] as int;
          final end = fields['end'] as int;

          final durDist = ExpDistribution(mean: meanDur);                //getting the distance of each event by ExpDistribution
          final intervalDist = ExpDistribution(mean: meanIntTime);       // getting the distance between 2 different events

          double currentTime = firstArrival.toDouble();                  //current time- gets updated later on
          while (currentTime <= end) {                                   //until end
            final duration = durDist.next().ceil();                      // Round to integer
            events.add(Event(name, currentTime.round(), duration));      //evenys get added
    
            final interval = intervalDist.next();                        //next event
            currentTime += interval;
          }
          break;
      }
    }
    events.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));      // sorts by arrival time
  }

/*
------------------------------------------------------------------------------------------
Simulation
------------------------------------------------------------------------------------------
*/

  void run() {
    int nextAvailable = 0;
    if (verbose) {
      print('\n[DEBUG] Starting simulation run');
    }
    for (Event a in events){                                  //goes through every event

      int wait = 0;
      if ((nextAvailable - a.arrivalTime) < 0){               //doesn't add negative wait times
        wait = 0;
      } else{
        wait = (nextAvailable - a.arrivalTime);
      }

      totalWait += wait;
      if (nextAvailable > a.arrivalTime){                     //counts the wait time
        nextAvailable += a.duration ;
      } else{
        nextAvailable = a.arrivalTime + a.duration;
      } 

    int totallength = events.length;
    final averageWait = totalWait/totallength;
    }
    return ;
  }
/*
------------------------------------------------------------------------------------------
Report
------------------------------------------------------------------------------------------
*/
  void printReport() {           
    if (verbose) {
      print('\n[DEBUG] Printing report');
    }
    
    print('# Simulation trace\n');
  for (Event event in events) {
    print('t=${event.startTime}: ${event.processName}, '
          'duration ${event.duration} started '
          '(arrived @ ${event.arrivalTime}, waited ${event.waitTime})');
  }

  // Per-process statistics
  Map<String, List<Event>> processMap = {};
  for (Event event in events) {
    processMap.putIfAbsent(event.processName, () => []).add(event);
  }

  print('\n--------------------------------------------------------------\n');
  print('# Per-process statistics\n');
  processMap.forEach((name, events) {
    int total = events.fold(0, (sum, e) => sum + e.waitTime);
    double avg = total / events.length;
    print('$name:');
    print('  Events generated:  ${events.length}');
    print('  Total wait time:   $total');
    print('  Average wait time: ${avg.toStringAsFixed(2)}');
  });
  
    print('\n--------------------------------------------------------------\n');
    print('# Summary statistics');
    int totallength = events.length;
    print('Total num events: $totallength');
    print ('Total wait time $totalWait');
    final averageWait = totalWait/totallength;
    print ("Average wait time $averageWait");
    return ;
  }
}

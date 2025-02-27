/// Base class for all process types.
abstract class Process {
  final String name;
  
  Process(this.name);
  
  /// Returns a list of all events generated by this process.
  List<Event> generateEvents();
}


/// An event that occurs once at a fixed time.
class Event {
  final String processName;
  final int arrivalTime;
  final int duration;
  int waitTime = 0;
  int startTime = 0;
  
  Event(this.processName, this.arrivalTime, this.duration);
}

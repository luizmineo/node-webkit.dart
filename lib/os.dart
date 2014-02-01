/**
 * Provides a few basic operating-system related utility functions.
 *
 * This library is a wrapper to the [nodejs's os module](http://nodejs.org/api/os.html).
 * 
 */
library os;

import 'dart:js';

import 'package:node_webkit/nodejs_module_wrapper.dart';


final NodeObject _os = new NodeObject("os");

/**
 * A constant defining the appropriate End-of-line marker for the operating system.
 *
 * See <http://nodejs.org/api/os.html#os_os_eol> for more information.
 */
final String EOL = _os["EOL"];

/**
 * Returns the operating system's default directory for temp files.
 *
 * See <http://nodejs.org/api/os.html#os_os_tmpdir> for more information.
 */
String tmpdir() {
  return _os.callFunction("tmpdir", []);
}

/**
 * Returns the endianness of the CPU. Possible values are "BE" or "LE".
 *
 * See <http://nodejs.org/api/os.html#os_os_endianness> for more information.
 */
String endianess() {
  return _os.callFunction("endianess", []);
}

/**
 * Returns the hostname of the operating system.
 *
 * See <http://nodejs.org/api/os.html#os_os_hostname> for more information.
 */
String hostname() {
  return _os.callFunction("hostname", []);
}

/**
 * Returns the operating system name.
 *
 * See <http://nodejs.org/api/os.html#os_os_type> for more information.
 */
String type() {
  return _os.callFunction("type", []);
}

/**
 * Returns the operating system platform.
 *
 * See <http://nodejs.org/api/os.html#os_os_platform> for more information.
 */
String platform() {
  return _os.callFunction("platform", []);
}

/**
 * Returns the operating system CPU architecture.
 *
 * See <http://nodejs.org/api/os.html#os_os_arch> for more information.
 */
String arch() {
  return _os.callFunction("arch", []);
}

/**
 * Returns the operating system release.
 *
 * See <http://nodejs.org/api/os.html#os_os_release> for more information.
 */
String release() {
  return _os.callFunction("release", []);
}

/**
 * Returns the system uptime in seconds.
 *
 * See <http://nodejs.org/api/os.html#os_os_uptime> for more information.
 */
int uptime() {
  return _os.callFunction("uptime", []);
}

/**
 * Returns a List containing the 1, 5, and 15 minute load averages.
 *
 * See <http://nodejs.org/api/os.html#os_os_loadavg> for more information.
 */
List<double> loadavg() {
  return new JsObjectListWrapper(_os.callFunction("loadavg", []));
}

/**
 * Returns the total amount of system memory in bytes.
 *
 * See <http://nodejs.org/api/os.html#os_os_totalmem> for more information.
 */
int totalmem() {
  return _os.callFunction("totalmem", []);
}

/**
 * Returns the amount of free system memory in bytes.
 *
 * See <http://nodejs.org/api/os.html#os_os_freemem> for more information.
 */
int freemem() {
  return _os.callFunction("freemem", []);
}

/**
 * Returns a List of objects containing information about each CPU/core installed.
 *
 * See <http://nodejs.org/api/os.html#os_os_cpus> for more information.
 */
List<CpuCore> cpus() {
  var list = new JsObjectListWrapper(_os.callFunction("cpus", []));
  var iterator = list.map((cpu) => new CpuCore(cpu));
  return new List<CpuCore>.from(iterator);
}

/**
 * Get a list of network interfaces.
 *
 * See <http://nodejs.org/api/os.html#os_os_networkinterfaces> for more information.
 */
Map<String, List<NetworkInterfaceAddr>> networkInterfaces() {
  return toMap(_os.callFunction("networkInterfaces", []), valueHandler: (addrs) {
    var list = new JsObjectListWrapper(addrs);
    var iterator = list.map((addr) => new NetworkInterfaceAddr(addr));
    return new List<NetworkInterfaceAddr>.from(iterator);
  });
}


class CpuCore {

  final JsObject _obj;

  CpuCoreTimes _times;

  CpuCore(this._obj) {
    _times = new CpuCoreTimes(_obj["times"]);
  }

  CpuCoreTimes get times => _times;

  String get model => _obj["model"];

  int get speed => _obj["speed"];

  String toString() =>
    'model: $model\n'
    'speed: $speed\n'
    'times: \n$times';
}

class CpuCoreTimes {

  final JsObject _obj;

  CpuCoreTimes(this._obj);

  int get user => _obj["user"];

  int get nice => _obj["nice"];

  int get sys => _obj["sys"];

  int get idle => _obj["idle"];

  int get irq => _obj["irq"];

  String toString() => 
    '  user: $user\n'
    '  nice: $nice\n'
    '  sys : $sys\n'
    '  idle: $idle\n'
    '  irq : $irq\n';
}

class NetworkInterfaceAddr {

  final JsObject _obj;

  NetworkInterfaceAddr(this._obj);

  String get address => _obj["address"];

  String get family => _obj["family"];

  bool get internal => _obj["internal"];

  String toString() =>
    'address: $address\n'
    'family: $family\n'
    'internal: $internal\n';

}

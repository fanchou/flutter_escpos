//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <flutter_usb_serial/flutter_usb_serial_plugin_c_api.h>
#include <quick_usb/quick_usb_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FlutterUsbSerialPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterUsbSerialPluginCApi"));
  QuickUsbPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("QuickUsbPlugin"));
}

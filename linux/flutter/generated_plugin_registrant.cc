//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <shared_preferences_linux/shared_preferences_linux_plugin.h>


void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) shared_preferences_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "SharedPreferencesPlugin");
  shared_preferences_linux_plugin_register_with_registrar(shared_preferences_linux_registrar);
}

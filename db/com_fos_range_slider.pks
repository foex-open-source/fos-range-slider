create or replace package com_fos_range_slider
as

    procedure render
      ( p_item apex_plugin.t_item
      , p_plugin in            apex_plugin.t_item
      , p_plugin in            apex_plugin.t_plugin
      , p_param  in            apex_plugin.t_item_render_param
      , p_result in out nocopy apex_plugin.t_item_render_result
      );

    procedure validate
      ( p_item apex_plugin.t_item
      , p_plugin in            apex_plugin.t_item
      , p_plugin in            apex_plugin.t_plugin
      , p_param  in            apex_plugin.t_item_validation_param
      , p_result in out nocopy apex_plugin.t_item_validation_result
      );

end;
/



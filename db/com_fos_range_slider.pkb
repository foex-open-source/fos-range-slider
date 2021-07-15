create or replace package body com_fos_range_slider
as

-- =============================================================================
--
--  FOS = FOEX Open Source (fos.world), by FOEX GmbH, Austria (www.foex.at)
--
--  This plug-in offers a range slider with various options.
--
--  License: MIT
--
--  GitHub:
--
-- =============================================================================
function split_string_into_words
  ( p_string          varchar2
  , p_word_sep_arr    apex_t_varchar2
  )
return apex_t_varchar2
as
    l_char      varchar2(1);
    l_word      varchar2(200);
    l_result    apex_t_varchar2 := apex_t_varchar2();

    -- add the word to the result array and clear the variable(l_word)
    procedure add_word
        ( p_word in out varchar2
        )
    as
    begin
        if p_word is not null
        then
            apex_string.push(l_result,p_word);
            p_word := null;
        end if;
    end add_word;

begin
    for idx in 1 .. length(p_string)
    loop
        l_char := substr(p_string,idx,1);

        if l_char member of p_word_sep_arr
        then
            -- if it's a special character, add the word and the char to the result array
            add_word(l_word);
            add_word(l_char);
        else
            l_word := l_word || l_char;
        end if;

    end loop;

    add_word(l_word);

    return l_result;
end split_string_into_words;

-- maps oracle date format to moment.js
function map_date_formats
  ( p_format      varchar2
  , p_date_format boolean default true
  , p_time_format boolean default true
  )
return varchar2
is
    l_js_format varchar2(200);
begin
    case upper(p_format)
        when '-'       then l_js_format := p_format;
        when ','       then l_js_format := p_format;
        when '.'       then l_js_format := p_format;
        when ';'       then l_js_format := p_format;
        when ':'       then l_js_format := p_format;
        when ' '       then l_js_format := p_format;
        when '/'       then l_js_format := p_format;
        when 'MI'      then l_js_format := case when p_time_format then 'm'    else '' end; -- minute 1,2,3,..., 60
        when 'AM'      then l_js_format := case when p_time_format then 'A'    else '' end; -- AM,PM
        when 'D'       then l_js_format := case when p_date_format then 'E'    else '' end; -- 1,2,3, ... ,7
        when 'DY'      then l_js_format := case when p_date_format then 'ddd'  else '' end; -- Mon, Tue, Wed, ...
        when 'DAY'     then l_js_format := case when p_date_format then 'dddd' else '' end; -- Monday, Tuesday, ...
        when 'FMDAY'   then l_js_format := case when p_date_format then 'dddd' else '' end; -- Monday, Tuesday, ...
        when 'DD'      then l_js_format := case when p_date_format then 'DD'   else '' end; -- 1,2,3, ...31
        when 'FMDD'    then l_js_format := case when p_date_format then 'D'    else '' end; -- 1,2,3, ...31
        when 'DDTH'    then l_js_format := case when p_date_format then 'DDDo' else '' end; -- 1st, 2nd, 3rd, ... ,31th
        when 'DDD'     then l_js_format := case when p_date_format then 'DDD'  else '' end; -- 1,2,3, ... ,365
        when 'HH'      then l_js_format := case when p_time_format then 'h'    else '' end; -- 1,2,3, ... ,12
        when 'HH12'    then l_js_format := case when p_time_format then 'hh'   else '' end; -- 01,02,03, ... ,12
        when 'HH24'    then l_js_format := case when p_time_format then 'HH'   else '' end; -- 01,02,03, ... ,24
        when 'FMHH'    then l_js_format := case when p_time_format then 'H'    else '' end; -- 1,2,3, ... ,12
        when 'FMHH12'  then l_js_format := case when p_time_format then 'h'    else '' end; -- 01,02,03, ... ,12
        when 'FMHH24'  then l_js_format := case when p_time_format then 'H'    else '' end; -- 01,02,03, ... ,24
        when 'IW'      then l_js_format := case when p_date_format then 'W'    else '' end; -- week of the year
        when 'IYYY'    then l_js_format := case when p_time_format then 'Y'    else '' end; -- 2020,2021,2022...
        when 'MI'      then l_js_format := case when p_time_format then 'm'    else '' end; -- minute 1,2,3,..., 60
        when 'M'       then l_js_format := case when p_time_format then 'M'    else '' end; -- month 1,2,3,..,12
        when 'MM'      then l_js_format := case when p_date_format then 'MM'   else '' end; -- month 01,02,03,..,12
        when 'MON'     then l_js_format := case when p_date_format then 'MMM'  else '' end; -- Jan, Feb, ... ,Dec
        when 'MONTH'   then l_js_format := case when p_date_format then 'MMMM' else '' end; -- January, February, ..., December
        when 'FMMONTH' then l_js_format := case when p_date_format then 'MMMM' else '' end; -- January, February, ..., December
        when 'PM'      then l_js_format := case when p_time_format then 'A'    else '' end; -- AM,PM
        when 'RR'      then l_js_format := case when p_date_format then 'YY'   else '' end; -- last two digits of the year
        when 'RRRR'    then l_js_format := case when p_date_format then 'YYYY' else '' end; -- 2020,2021,...
        when 'SS'      then l_js_format := case when p_time_format then 's'    else '' end; -- seconds 1,2,3,...,59
        when 'WW'      then l_js_format := case when p_date_format then 'w'    else '' end; -- week of the year (bit different than the iw)
        when 'YY'      then l_js_format := case when p_date_format then 'YY'   else '' end; -- last two digits of the year
        when 'YYYY'    then l_js_format := case when p_date_format then 'YYYY' else '' end;
        when 'XFF'     then l_js_format := case when p_time_format then '.u'   else '' end;
        when 'TZR'     then l_js_format := case when p_time_format then 'z'    else '' end; -- timezone
        --
        -- date format not found
        -- should we do more guessing or raise an exception ???
        else
            l_js_format := '';
    end case;

    return l_js_format;

end map_date_formats;

-- calls the combination of the two functions above
function oracle_to_js_date_format
  ( p_oracle_format varchar2
  )
return varchar2
as
    l_date_parts   apex_t_varchar2;
    -- possible characters used in the date format as a separator
    l_date_sep_arr apex_t_varchar2 := apex_t_varchar2('-',',','.',';',':',' ','/');
    l_result       varchar2(400);
begin
    l_date_parts := split_string_into_words
                      ( p_string       => p_oracle_format
                      , p_word_sep_arr => l_date_sep_arr
                      );
    for i in 1 .. l_date_parts.count
    loop
        l_result := l_result || map_date_formats(l_date_parts(i));
    end loop;

    return l_result;
end oracle_to_js_date_format;

procedure render
  ( p_item   in            apex_plugin.t_item
  , p_plugin in            apex_plugin.t_plugin
  , p_param  in            apex_plugin.t_item_render_param
  , p_result in out nocopy apex_plugin.t_item_render_result
  )
as
    l_item_id              p_item.id%type             := p_item.id;
    l_item_name            p_item.name%type           := p_item.name;
    l_item_value           p_param.value%type         := p_param.value;
    l_item_value_arr       apex_t_varchar2            := apex_string.split(l_item_value, ':');
    l_item_height          p_item.element_height%type := p_item.element_height;
    l_init_js              varchar2(32767)            := nvl(apex_plugin_util.replace_substitutions(p_item.init_javascript_code), 'undefined');
    l_date_format          p_item.format_mask%type    := nvl(p_item.format_mask, :APP_NLS_DATE_FORMAT);

    --attributes
    l_type                 p_item.attribute_01%type   := p_item.attribute_01;
    l_handles              p_item.attribute_02%type   := p_item.attribute_02;
    l_min_range            p_item.attribute_03%type   := p_item.attribute_03;
    l_max_range            p_item.attribute_04%type   := p_item.attribute_04;
    l_min_date             p_item.attribute_05%type   := p_item.attribute_05;
    l_max_date             p_item.attribute_06%type   := p_item.attribute_06;
    l_date_steps           p_item.attribute_07%type   := p_item.attribute_07;
    l_number_steps         p_item.attribute_08%type   := p_item.attribute_08;
    l_orientation          p_item.attribute_09%type   := p_item.attribute_09;
    l_options              p_item.attribute_10%type   := p_item.attribute_10;
    l_enable_tooltips      boolean                    := instr(l_options, 'enable-tooltip'    ) > 0;
    l_enable_ticks         boolean                    := instr(l_options, 'enable-ticks'      ) > 0;
    l_return_value_item    boolean                    := instr(l_options, 'bind-value-to-item') > 0;
    l_connect_bar          boolean                    := instr(l_options, 'connects-bar'      ) > 0;
    l_flip_range           boolean                    := instr(l_options, 'flip-range'        ) > 0;
    l_ticks_num            p_item.attribute_11%type   := p_item.attribute_11;
    l_return_item          p_item.attribute_12%type   := p_item.attribute_12;
    l_range_color          p_item.attribute_13%type   := p_item.attribute_13;
    -- local variables
    l_step                 varchar2(100);
    l_min_value            varchar2(1000);
    l_max_value            varchar2(1000);
    l_number_separator     varchar2(10);
    l_js_date_format       varchar2(1000);
begin
    -- standard debugging
    if apex_application.g_debug
    then
        apex_plugin_util.debug_page_item
          ( p_plugin    => p_plugin
          , p_page_item => p_item
          );
    end if;

    if l_type = 'date'
    then
        -- transform the oracle date format into js specific (momentjs)
        l_js_date_format := oracle_to_js_date_format(l_date_format);
        -- set the date_steps to the step value
        l_step := l_date_steps;
        -- set the min and max values;
        l_min_value := l_min_date;
        l_max_value := l_max_date;
    else
        -- get the language dependent decimal separator
        select substr(value,1,1)
          into l_number_separator
          from nls_session_parameters
         where parameter = 'NLS_NUMERIC_CHARACTERS'
        ;

        -- pass the number_steps as the step value
        l_step := l_number_steps;
        -- set the min and max values
        l_min_value := l_min_range;
        l_max_value := l_max_range;
    end if;

    --set initial values for item
    -- if there's no value provided, then we use the min - and - max values
    if l_item_value is null
    then
        if l_type = 'number'
        then
            apex_string.push(l_item_value_arr, l_min_range);
            apex_string.push(l_item_value_arr, l_max_range);
        else
            apex_string.push(l_item_value_arr, l_min_date);
            apex_string.push(l_item_value_arr, l_max_date);
        end if;
    end if;

    --print container div
    sys.htp.p('<div class="range-slider-'|| l_orientation ||'" id="'  || l_item_name || '"></div>');

    --creating json
    apex_json.initialize_clob_output;
    apex_json.open_object;

    apex_json.write('type'                  , l_type                            );
    apex_json.write('handles'               , l_handles                         );
    apex_json.write('minimumValue'          , l_min_value                       );
    apex_json.write('maximumValue'          , l_max_value                       );
    apex_json.write('itemHeight'            , l_item_height                     );
    apex_json.write('rangeColor'            , l_range_color                     );
    apex_json.write('showTicks'             , l_enable_ticks                    );
    apex_json.write('ticks'                 , l_ticks_num                       );
    apex_json.write('orientation'           , l_orientation                     );
    apex_json.write('tooltip'               , l_enable_tooltips                 );
    apex_json.write('returnValToItem'       , l_return_value_item               );
    apex_json.write('step'                  , l_step                            );
    apex_json.write('retItems'              , l_return_item                     );
    apex_json.write('connectBar'            , l_connect_bar                     );
    apex_json.write('flipRange'             , l_flip_range                      );
    apex_json.write('itemName'              , l_item_name                       );
    apex_json.write('dateFormat'            , l_js_date_format                  );
    apex_json.open_object('numberFormat');
    apex_json.write('mark'                  , l_number_separator                );
    apex_json.close_object;
    apex_json.open_array('value');

    for i in 1 .. l_item_value_arr.count
    loop
        if l_type = 'number'
        then
            apex_json.write(l_item_value_arr(i));
        else
            apex_json.write(to_date(l_item_value_arr(i),l_date_format));
        end if;
    end loop;

    apex_json.close_array;

    apex_json.close_object;

    apex_javascript.add_onload_code(p_code => 'FOS.item.rangeSlider.init(' || apex_json.get_clob_output || ',' || l_init_js || ');');

    apex_json.free_output;

end render;

procedure validate
  ( p_item   in             apex_plugin.t_item
  , p_plugin in             apex_plugin.t_plugin
  , p_param  in             apex_plugin.t_item_validation_param
  , p_result in out nocopy  apex_plugin.t_item_validation_result
  )
as
    l_value          p_param.value%type       := p_param.value;
    l_date_format    p_item.format_mask%type  := nvl(p_item.format_mask, :APP_NLS_DATE_FORMAT);
    l_type           p_item.attribute_01%type := p_item.attribute_01;
    l_min_range      p_item.attribute_03%type := p_item.attribute_03;
    l_max_range      p_item.attribute_04%type := p_item.attribute_04;
    l_min_date       p_item.attribute_05%type := p_item.attribute_05;
    l_max_date       p_item.attribute_06%type := p_item.attribute_06;

    l_min_date_value date;
    l_max_date_value date;

    l_values         apex_t_varchar2;
    l_num_value      number;
    l_date_value     date;
begin

    if l_type = 'date'
    then
        l_min_date_value := to_date(l_min_date, l_date_format);
        l_max_date_value := to_date(l_max_date, l_date_format);
    end if;

    l_values := apex_string.split(l_value, ':');

    for i in 1 .. l_values.count
    loop
        if l_type = 'number'
        then
            l_num_value := to_number(l_values(i));
            if l_num_value < l_min_range or l_num_value > l_max_range
            then
                p_result.message := 'Number is not in range';
            end if;
        elsif l_type = 'date'
        then
            l_date_value := to_date(l_values(i),l_date_format);
            if l_date_value < l_min_date_value or l_date_value > l_max_date_value
            then
                p_result.message := 'Date is not in range';
            end if;
        end if;
    end loop;

end validate;


end;
/



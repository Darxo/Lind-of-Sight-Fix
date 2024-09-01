::include("mod_LOSFIX/msu_settings");
::include("mod_LOSFIX/cube_coordinates");
::include("mod_LOSFIX/logic");

::includeFiles(::IO.enumerateFiles("mod_LOSFIX/hooks"));		// This will load and execute all hooks

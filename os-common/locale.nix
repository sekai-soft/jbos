varsPath:

{ ... }:

let
  vars = import varsPath;
in
{
  time.timeZone = vars.timezone;
  i18n.defaultLocale = vars.locale;
}

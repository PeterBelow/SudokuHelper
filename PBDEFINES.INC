{$BOOLEVAL OFF}{Most units depend on shortcut boolean evaluation}
{$IFDEF WIN32}{$DEFINE COMPILER2_UP}{$ENDIF}
{$IFDEF ConditionalExpressions}
  {$DEFINE COMPILER6_UP}
  {$IF CompilerVersion > 16} {Delphi 2005 or newer}
    {$DEFINE SUPPORTS_INLINE}
    {$DEFINE IGNOREFILEAGEWARNING}
  {$IFEND}
  {$IF CompilerVersion > 17} {Delphi 2006 or newer}
    {$DEFINE SUPPORTS_CLASS_ABSTRACT}
    {$DEFINE SUPPORTS_STRICT}
    {$DEFINE SUPPORTS_STATIC}
    {$DEFINE SUPPORTS_PADDING}
    {$DEFINE SUPPORTS_CLASSHELPERS}
    {$DEFINE SUPPORTS_RECORDHELPERS}
    {$DEFINE RECORDS_WITH_METHODS}
  {$IFEND}
  {$IF CompilerVersion > 19} {Delphi 2009 or newer}
    {$DEFINE SUPPORTS_DEPRECATEDMSG}
    {$DEFINE SUPPORTS_ANONYMOUS_METHODS}
    {$DEFINE SUPPORTS_GENERICS}
    {$DEFINE SUPPORTS_TSTRINGBUILDER}
    {$DEFINE SUPPORTS_POINTERMATH}
  {$IFEND}
  {$IF CompilerVersion > 20} {Delphi 2010 or newer}
    {$DEFINE SUPPORTS_START}
    {$DEFINE SUPPORTS_XBUTTONS}
    {$DEFINE SUPPORTS_NATIVE_INT}
    {$DEFINE SUPPORTS_Diagnostics}
    {$IFDEF NO_RTTI}
      { $RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
      {Cannot use the above, it causes an internal error when enabled and
       this include file is included above the unit directive.}
    {$ENDIF}
  {$IFEND}
  {$IF CompilerVersion > 21} {Delphi 2011/XE or newer}
    {$DEFINE SUPPORTS_REGEX}
    {$DEFINE USE_TFORMATSETTINGS}
    {$DEFINE SUPPORTS_TInterlocked}
    {$DEFINE SUPPORTS_TGuid_operators}
  {$IFEND}
  {$IF CompilerVersion > 22} {Delphi XE2 or newer}
    {$DEFINE SUPPORTS_STYLESERVICES}
    {$DEFINE SUPPORTS_TRECTMETHODS}
    {$DEFINE USE_UITYPES}
  {$IFEND}
  {$IF CompilerVersion > 23} {Delphi XE3 or newer}
    {$DEFINE USE_SYSTEM_ACTIONS}
    {$DEFINE SUPPORTS_STRINGHELPER}
  {$IFEND}
  {$IF CompilerVersion > 24} {Delphi XE4 or newer}
    {$DEFINE USE_ANSISTRINGS}
    {$DEFINE SUPPORTS_CHARHELPER}
    {$DEFINE SUPPORTS_NEXTGEN}
  {$IFEND}
  {$IF DEFINED(WEAKINTFREF) OR (CompilerVersion >= 31)}
    {10.1 Berlin or newer}
     {$DEFINE SUPPORTS_WEAK_INTF}
     {$DEFINE PBLIBRARY}
  {$IFEND}
  {$IF CompilerVersion >= 32} {Delphi Tokyo or newer}
    {$DEFINE PATCH_AcquireExceptionObject}
  {$IFEND}
  {$IF CompilerVersion >= 34} {Delphi Sydney or newer}
    {$DEFINE SUPPORTS_STYLESERVICES2}
  {$IFEND}
  {$IF CompilerVersion >= 35} {Delphi Alexandria or newer}
    {$DEFINE SUPPORTS_LOCKDRAWING}
  {$IFEND}
  {$IF defined(CPUX64)}
    {$DEFINE WIN64}
  {$IFEND}
{$ENDIF}
{$WARN SYMBOL_PLATFORM OFF}
{$WARN UNIT_PLATFORM OFF}





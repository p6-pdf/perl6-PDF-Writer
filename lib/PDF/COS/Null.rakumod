use v6;

unit class PDF::COS::Null;
also is Any;

use PDF::COS;
also does PDF::COS;

method defined { False }
method content { :null(Any) };
multi method ACCEPTS(Any:U) { True }



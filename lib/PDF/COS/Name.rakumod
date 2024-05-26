use v6;

role PDF::COS::Name {
    use PDF::COS;
    also does PDF::COS;

    method content { :name(self.fmt) }
    proto method COERCE($){*}
    multi method COERCE(PDF::COS::Name:D $_) is default { $_ }
    multi method COERCE(Str:D $str) { $str but PDF::COS::Name }
}


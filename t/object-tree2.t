use v6;
use PDF::Object;
use PDF::Tools::IndObj;
use Test;

our %ties;
our $dummy-reader;

class t::DummyReader {
    method ind-obj($obj-num, $gen-num) {
        %ties{$obj-num}{$gen-num} //= do {
            my %dict = :Type<Test>,
            :Desc("tie to: $obj-num $gen-num R");

            my $ind-obj = [$obj-num,$gen-num, :%dict];

            PDF::Tools::IndObj.new( :$ind-obj, :reader(self) );
        }
    }
}

$dummy-reader = t::DummyReader.new;

my $obj = PDF::Object.compose: :dict{
    :A(10),
    :B(:ind-ref[42,5]),
    :Kids[
         42,
         { :X(99) },
         :ind-ref[99,0],
        ],
};

$obj.reader = $dummy-reader;

is $obj<A>, 10, 'shallow reference';
is_deeply $obj<B>, {Desc => "tie to: 42 5 R", :Type("Test")}, 'hash dereference';
is_deeply $obj<Kids>[2], {Desc => "tie to: 99 0 R", :Type("Test")}, 'array dereference';
$obj<B><SubRef> = :ind-ref[77, 0];
is_deeply $obj<B><SubRef>, {Desc => "tie to: 77 0 R", :Type("Test")}, 'new hash entry';
lives_ok {++$obj<A>}, 'shallow reference preincrement';
is_deeply $obj<Kids>[0], (42), 'deep reference';
is $obj<Kids>[1]<X>, 99, 'deep reference';
lives_ok {$obj<Kids>[1]<X>++;}, 'deep post increment';
is $obj<Kids>[1]<X>, 100, 'incremented';
$obj<Kids>.push( (:ind-ref[123,0]) );
is_deeply $obj<Kids>[3], {Desc => "tie to: 123 0 R", :Type("Test")}, 'new array entry';

done;


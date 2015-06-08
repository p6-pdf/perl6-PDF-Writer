use v6;

use PDF::Object :from-ast, :to-ast-native;
use PDF::Object::DOM;
use PDF::Object::Tree;

#| Dict - base class for dictionary objects, e.g. Catalog Page ...
class PDF::Object::Dict
    is PDF::Object
    is Hash
    does PDF::Object::DOM
    does PDF::Object::Tree {

    our %obj-cache = (); #= to catch circular references

    method new(Hash :$dict = {}, *%etc) {
        my $id = ~$dict.WHICH;
        my $obj = %obj-cache{$id};
        unless $obj.defined {
            temp %obj-cache{$id} = $obj = self.bless(|%etc);
            # this may trigger cascading PDF::Object::Tree coercians
            # e.g. native Array to PDF::Object::Array
            $obj{ .key } = from-ast(.value) for $dict.pairs;
            $obj.cb-setup-type($obj);
        }
        $obj;
    }

    method content {
        to-ast-native self;
    }
}

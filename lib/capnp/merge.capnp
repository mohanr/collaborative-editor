@0xc6f77289e1b5b950;

struct VersionTuple{
    key @0 :Text;
    value @1 :Int16;
}

interface MergeDoc {
  mergedoc @0 (doccontent :List(VersionTuple),
                versionlist :List(Int16)) -> ();
}

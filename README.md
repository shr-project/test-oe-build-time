# test-oe-build-time

Tests build time on non-trivial OE build.

Uses hardcoded git revisions of each layer, to make it reproducible.

For the test scripts and README.md how to run them see the branches for
each OE branch, most available results are from 'zeus', but zeus isn't
supported anymore for a while and it won't be compatible with recent
distributions on host. You can always add buildtools tarball or run it
inside some container, but that might affect the build time as well, so
use it only if you plan to run your OE builds that way as well.

=== Results ===
.csv and .ods is in the repository. The same is also imported in google docs:
https://docs.google.com/spreadsheets/d/1qtpACcUO0T1bhHPZxDQFvtYEesNTTfxuvFYFdU8kyjI/edit?usp=sharing

and the html version:
https://docs.google.com/spreadsheets/d/e/2PACX-1vSQmFvqik7MRumLafiZgwjE3IMLLcQY-71F3zNz9GuG8uzRb5FIp97uUqq6Qh3qWXQEWRK7Y9Hv2nXt/pubhtml#

[Various load graphs can be found in this list](Graphs.md)

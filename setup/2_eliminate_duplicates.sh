#!/bin/bash
#
#

parmed="$AMBERHOME/bin/parmed"


$parmed -p protein.parm7 <<_EOF
loadRestrt protein.rst7
setOverwrite True
tiMerge :1-286 :287-572 :44 :330
outparm merged_protein.parm7 merged_protein.rst7
quit
_EOF

$parmed -p complex.parm7 <<_EOF
loadRestrt complex.rst7
setOverwrite True
tiMerge :1-286 :287-572 :44 :330
outparm merged_complex.parm7 merged_complex.rst7
quit
_EOF

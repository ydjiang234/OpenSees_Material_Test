wipe;
model BasicBuilder -ndm 2 -ndf 3;
set protocol [list 0.0 1.0 -1.0 2.0 -2.0 3.0 -3.0];
set d_incr 0.1;
#Node
node 1 0.0 0.0;
node 2 0.0 0.0;
fix 1 1 1 1;

#Material
set E 1.0;
set fyt 1.0;
set fyn -1.5; 
set bt 0.05; 
set bn 0.01;
uniaxialMaterial testBilin 1 $E $fyt $fyn $bt $bn;


#Section
section Uniaxial 1 1 Mz;
#section Aggregator 1 1 P 1 Vy 1 Mz 1 Vz 1 T 1 Vz;

#Zero length element
geomTransf Linear 1;
element zeroLengthSection 1 1 2 1;
#element dispBeamColumn 1 1 2 10 1 1;
equalDOF 1 2 1 2;

#Disp Control 
timeSeries Linear 1;
pattern Plain 1 1 {
    load 2 0.0 0.0 1.0;
}

#recorder
recorder Node -file "Disp.out" -time -node 2  -dof 3 disp;
recorder Element -file "Force.out"  -time -ele 1 forces;

#Analysis
for {set i 1} {$i < [llength $protocol]} {incr i} {
    set cur_disp [expr [lindex $protocol $i] - [lindex $protocol [expr $i - 1]]];
    if {$cur_disp > 0.0} {
        integrator DisplacementControl 2 3 $d_incr;
    } else {
        integrator DisplacementControl 2 3 -$d_incr;
    }
    constraints Plain;
    numberer Plain;
    system BandGeneral;
    test NormDispIncr 1.0e-3 50;
    algorithm Newton;
    analysis Static;
    analyze [expr int(abs($cur_disp / $d_incr))];
    set a [eleResponse 1 forces];
    #puts [lindex $a 1];
}


requires "../configuration.k"

module CONDITION
    imports CONFIGURATION
    imports BOOL
    imports MAP
    imports K-EQUAL

    rule <k> bool BN:BoolId B:Bool ; => . ...</k>
        <bools> M:Map => M [ BN <- B ] </bools>

    rule <k> if ( CE:CondExp ) { SL:StmtList } 
            => if ( CE ) { SL } else { .StmtList }
            ...
        </k>

    rule <k> if ( CE:CondExp ) { SL1:StmtList } else { SL2:StmtList }
            => #if CondExpEval(CE) #then { SL1 } #else { SL2 } #fi
        ...</k>

    rule <k> { S:Stmt SL:StmtList } => S ~> { SL } ...</k>
    rule <k> { .StmtList } => . ...</k>

    // todo ?
    syntax Bool ::= "CondExpEval" "(" CondExp ")" [function]
    rule CondExpEval(! E:CondExp) => notBool CondExpEval(E)
    rule CondExpEval(E1:CondExp && E2:CondExp) => CondExpEval(E1) andBool CondExpEval(E2)
    rule CondExpEval(E1:CondExp || E2:CondExp) => CondExpEval(E1) orBool  CondExpEval(E2)
    rule CondExpEval(E1:CondExp != E2:CondExp) => CondExpEval(E1) =/=Bool CondExpEval(E2)
    rule CondExpEval(E1:CondExp == E2:CondExp) => CondExpEval(E1) ==Bool  CondExpEval(E2)
    rule [[ CondExpEval(E:BoolId) => B ]] 
        <bools>... E |-> B:Bool ...</bools>

endmodule
requires "../configuration.k"
requires "../selinux-syntax.k"

module MLS
    imports CONFIGURATION
    imports SET
    imports BOOL
    imports MAP
    
    rule <k> (sensitivity SN:SensId ;):SensDecl => . ...</k>
        <sensitivities> S => S SetItem(SN) </sensitivities>
        requires notBool SN in S

    rule <k> sensitivity SN:SensId alias SAN:SensAliasName SANs:SensAliasNames ;
            => sensitivity SN alias SANs ;
        ...</k>
        <sens-alias> M => M SAN |-> SN </sens-alias>
    rule <k> sensitivity SN:SensId alias .SensAliasNames ; => . ...</k>
        <sensitivities> S => S SetItem(SN) </sensitivities>
        // requires notBool SN in S

    // todo: may exist some problems
    rule <k> level SN:SensId ; => . ...</k>
        <levels> M => M SN |-> .CategorySet </levels>
        // requires notBool SN in_keys(M)
    rule <k> level SN:SensId : CS:CategorySet ; => . ...</k>
        <levels> M => M SN |-> CS </levels>
        // <categories> CATEGORIES </categories>
        // requires CS in CATEGORIES andBool notBool L in S

    rule <k> (category CN:CategoryId ;):CategoryDecl => . ...</k>
        <categories> S => S SetItem(CN) </categories>
        requires notBool CN in S
    
    rule <k> category CN:CategoryId alias CAN:CategoryAliasName CANs:CategoryAliasNames ; 
            => category CN alias CANs ; 
        ...</k>
        <categories> CATEGORIES </categories>
        <category-alias> M => M CAN |-> CN </category-alias>
        requires notBool CN in CATEGORIES andBool notBool CAN in_keys(M)
    
    rule <k> category CN:CategoryId alias .CategoryAliasNames ; => . ...</k>
        <categories> S => S SetItem(CN) </categories>
        requires notBool CN in S

    rule <k> dominance { SNs:SensIds } => . ...</k>
        <dominances> S => S SetItem(SNs) </dominances>

    // rule <k> mlsconstrain _CS:ClassSet _PS:PermSet _E:MlsExp ; => . ...</k>
    rule <k> mlsconstrain { C:ClassId CNs:ClassIds } PS:PermSet E:MlsExp ;
            => mlsconstrain C PS E ;
            ~> mlsconstrain { CNs } PS E ;
        ...</k>
    rule <k> mlsconstrain { .ClassIds } _PS:PermSet _E:MlsExp ; => . ...</k>
    rule <k> mlsconstrain C:ClassId { P:PermId PS:PermIds } E:MlsExp ;
            => mlsconstrain C P E ;
            ~> mlsconstrain C { PS } E ;
        ...</k>
    rule <k> mlsconstrain _C:ClassId { .PermIds } _E:MlsExp ; => . ...</k>

    // rule <k> mlsconstrain C:ClassId P:PermId E:MlsExp ; => . ...</k>
    //     <mlsconstrains> M => M (C P) |-> SetItem(E) </mlsconstrains>
    //     requires notBool (C P) in_keys(M)
    // rule <k> mlsconstrain C:ClassId P:PermId E:MlsExp ; => . ...</k>
    //     <mlsconstrains>... (C P) |-> S => (C P) |-> S SetItem(E) ...</mlsconstrains>
    rule <k> mlsconstrain C:ClassId P:PermId E:MlsExp ; => . ...</k>
        <mlsconstrains>
            M:Map => M [(C P) <- SetItem(E) |Set setFromKItem(M[(C P)] orDefault .Set)]
        </mlsconstrains>
        requires ( isWritePerm(P) impliesBool canMlsWrite(E) ) 
            andBool ( isReadPerm(P) impliesBool canMlsRead(E) ) 
    
    rule <k> mlsvalidatetrans _CS:ClassSet _ME:MlsExp ; => . ...</k>

    syntax ClassPermPair ::= "(" ClassId PermId ")"


    // syntax Bool ::= isMlsSafe(MlsExp) [function]

    // rule isMlsSafe(E1:MlsExp or E2:MlsExp)  => isMlsSafe(E1) orBool  isMlsSafe(E2)
    // rule isMlsSafe(E1:MlsExp and E2:MlsExp) => isMlsSafe(E1) andBool isMlsSafe(E2)
    // rule isMlsSafe(_E1:Name _Op:BoolOp _E2:Name) => false
    // rule isMlsSafe(_) => true [owise]

    syntax Bool ::= canMlsWrite(MlsExp) [function]
    syntax Bool ::= canMlsRead(MlsExp) [function]

    rule canMlsRead(_) => false
    rule canMlsWrite(_) => false
endmodule
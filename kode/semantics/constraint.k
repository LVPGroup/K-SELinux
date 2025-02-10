requires "../configuration.k"

module CONSTRAINT
    imports CONFIGURATION
    imports SET
    imports MAP
    imports BOOL

    // rule <k> _:ConstrainStmt => . ...</k>

    rule <k> validatetrans { C:ClassId CNs:ClassIds } CE:ConstraintExp ; 
            => validatetrans C CE ; ~> validatetrans { CNs } CE ;
        ...</k>
    rule <k> validatetrans { .ClassIds } _CE:ConstraintExp ; => . ...</k>
    
    rule <k> validatetrans C:ClassId CE:ConstraintExp ; => . ...</k>
        <validatetrans> 
            M:Map => M [ C <- SetItem(CE) |Set {M[C] orDefault .Set}:>Set ]
        </validatetrans>

    // constrain statement
    rule <k> constrain { C:ClassId CNs:ClassIds } PS:Perms ( CE:ConstraintExp ) ;
            => constrain C PS ( CE ) ; ~> constrain { CNs } PS ( CE ) ;
        ...</k>
    rule <k> constrain { .ClassIds } _PS:Perms ( _CE:ConstraintExp ) ; => . ...</k>
    
    rule <k> constrain C:ClassId { P:PermId PS:PermIds } ( CE:ConstraintExp ) ;
            => constrain C P ( CE ) ; ~> constrain C { PS } ( CE ) ;
        ...</k>
    rule <k> constrain _C:ClassId { .PermIds } ( _CE:ConstraintExp ) ; => . ...</k>

    rule <k> constrain C:ClassId P:PermId ( CE:ConstraintExp ) ; => . ...</k>
        <constraints>
            M:Map => M [ (C P) <- SetItem(CE) |Set {M[(C P)] orDefault .Set}:>Set ]
        </constraints>
        
endmodule
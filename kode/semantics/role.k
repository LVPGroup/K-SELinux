requires "../configuration.k"

module ROLE
    imports CONFIGURATION
    imports SET
    imports BOOL
    imports LIST
    
    // rule <k> _:RoleDeclStmt => . ...</k>
    rule <k> (role R:RoleId ;):RoleDeclStmt => . ...</k>
        <roles> S:Set => S SetItem(R) </roles>
        // requires notBool R in S
    
    rule <k> role R:RoleId types T:TypeId ; => . ...</k>
        <roles> S:Set => S SetItem(R) </roles>
        <role-types> 
            M:Map => M [ R <- SetItem(T) |Set {M[R] orDefault .Set}:>Set ]
        </role-types>
        // requires notBool R in S
    

    // role declaration
    // There can be multiple role statements for the same role identifier.
    // rule <k> RD:RoleDecl => mark_RoleDecl RD ...</k>
    

    // rule <k> mark_RoleDecl role R:RoleId ; => . ...</k>
        // <roles> S => S SetItem(R) </roles>
    // requires notBool R in S

    // rule <k> mark_RoleDecl role R:RoleId types TS:TypeSet ; => . ...</k>
        // <roles> S => S SetItem(R) </roles>
        // <role-types> M => M R |-> TypeSet2Set(TS) </role-types>
    // requires notBool R in S


    // role dominance
    rule <k> _:RoleDomStmt => . ...</k>
    // rule <k> dominance { D:Dominance } => . ...</k>
    //     <dominance> S => S SetItem(DominanceList(D)) </dominance>
    // rule <k> mark_Dominance _:RoleItems { _:Dominance } => . ...</k>
    // rule <k> mark_Dominance _:RoleItems ; => . ...</k>
    // todo: dominance detail

    
    // role allow statement
    // rule <k> allow { R:RoleId RNs:RoleIds } RS:RoleSet ; 
    //         => allow R RS ; 
    //         ~> allow { RNs } RS ; 
    //     ...</k>
    // rule <k> allow { .RoleIds } _RS:RoleSet ; => . ...</k>

    rule <k> _:RoleAllowStmt => . ...</k>
    // rule <k> allow R:RoleId RS:RoleSet ; => . ...</k>
    //     <roleAllow> M => M R |-> RoleSet2Set(RS) </roleAllow>
    // requires notBool R in_keys(M)

    // rule <k> allow R:RoleId RS:RoleSet ; => . ...</k>
    //     <roleAllow>... R |-> (S => S RoleSet2Set(RS)) ...</roleAllow>

    // rule <k> allow R:RoleId RS:RoleSet ; => . ...</k>
    //     <roleAllow> 
    //         M:Map => M [R <- RoleSet2Set(RS) |Set setFromKItem(M[R] orDefault .Set)]
    //     </roleAllow>
    // requires notBool R in_keys(M)
    

    rule <k> _:RoleTransitionStmt => . ...</k>
    // role transition statement
    // rule <k> role_transition { R1:RoleId RNs:RoleIds } TS:TypeSet R:RoleId ; 
    //         => role_transition R1 TS R ; 
    //         ~> role_transition { RNs } TS R ;
    //     ...</k>
    // rule <k> role_transition { .RoleIds } _TS:TypeSet _R2:RoleId ; => . ...</k>

    // rule <k> role_transition R1:RoleId { T:TypeId TNs:TypeIds } R2:RoleId ;
    //         => role_transition R1 T R2 ;
    //         ~> role_transition R1 { TNs } R2 ;
    //     ...</k>
    // rule <k> role_transition _R1:RoleId { .TypeIds } _R2:RoleId ; => . ...</k>

    // rule <k> role_transition R1:RoleId T:TypeId R2:RoleId ; => . ...</k>
    //     <roleTrans> S => S SetItem((R1 T R2)) </roleTrans>
    // todo: ensure types declared

    
    // user declaration
    rule <k> user U:UserId roles _R:Roles ; => . ...</k>
        <users> S:Set => S SetItem(U) </users>
        // <user-roles> M:Map => M [U <- RoleSet2Set(R)] </user-roles>

    
    // attribute role declaration
    rule <k> (attribute_role A:AttrId ;):AttrRoleStmt => . ...</k>
        <attr-roles> M:Map => M [A <- .Set] </attr-roles>
        requires notBool A in_keys(M)
    
    rule <k> roleattribute R:RoleId A:AttrId ; => . ...</k>
        <attr-roles>... A |-> (S => S SetItem(R)) ...</attr-roles>
    // requires AR is defined implicitly


    // syntax Set ::= RoleSet2Set(Roles) [function]
    // rule RoleSet2Set(R:RoleId) => SetItem(R)
    // rule RoleSet2Set({ .RoleIds }) => .Set
    // rule RoleSet2Set({ R:RoleId RS:RoleIds }) => SetItem(R) RoleSet2Set({ RS })

    // syntax Set ::= TypeSet2Set(Types) [function]
    // rule TypeSet2Set(T:TypeId) => SetItem(T)
    // rule TypeSet2Set({ .TypeIds }) => .Set
    // rule TypeSet2Set({ T:TypeId TS:TypeIds }) => SetItem(T) TypeSet2Set({ TS })
    
    // syntax RoleTransRuleItem ::= "(" RoleId TypeId RoleId ")"

    // syntax List ::= DominanceList(Dominance) [function]
    // rule DominanceList(R:RoleItems ;) => ListItem(R)
    // rule DominanceList(R:RoleItems { D:Dominance }) => ListItem(R) DominanceList(D)

endmodule
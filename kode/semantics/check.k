requires "../configuration.k"

module CHECK-ALL
    imports PARSE-END
    imports CHECK-0
    imports CHECK-1
    imports CHECK-2
endmodule

module PARSE-END
    imports CONFIGURATION
    imports K-EQUAL

    syntax Controller ::= "constraint-fail"
                        | "constraint-check"
                        | "constraint-check-end"

    rule <k> parse-end
            => constraint-check ~> Rs 
            ~> constraint-check-end
            ...
        </k>
        <allow> Rs:Set </allow>

    rule <k> constraint-check-end => check ...</k>

    rule <k> constraint-fail 
            ~> allow T1:TypeId T2:TypeId : C:ClassId P:PermId
            => . ...
        </k>
        <constraint-failed> 
            S:Set => S SetItem(allow T1 T2 : C P)
        </constraint-failed>

    rule <k> constraint-check ~> .Set => . ...</k>
    rule <k> constraint-check
            ~> SetItem(allow T1:TypeId T2:TypeId : C:ClassId P:PermId) Rs:Set 
            => #if constraintExpsEval(T1 T2 {M[(C P)] orDefault .Set}:>Set)
                #then .
                #else constraint-fail ~> allow T1 T2 : C P
                #fi
            ~> constraint-check ~> Rs
            ...
        </k>
        <constraints> M:Map </constraints>

    
    syntax Bool ::= "constraintExpsEval" "(" TypeId TypeId Set ")" [function]

    rule constraintExpsEval(_:TypeId _:TypeId .Set) => true

    rule constraintExpsEval(T1:TypeId T2:TypeId SetItem(E:ConstraintExp) Exps:Set)
        => constraintExpEval(T1 T2 E) andBool constraintExpsEval(T1 T2 Exps)

    syntax Bool ::= "constraintExpEval" "(" TypeId TypeId ConstraintExp ")" [function]
    
    rule constraintExpEval(T1:TypeId T2:TypeId E1:ConstraintExp and E2:ConstraintExp)
        => constraintExpEval(T1 T2 E1) andBool constraintExpEval(T1 T2 E2)
    
    rule constraintExpEval(T1:TypeId T2:TypeId E1:ConstraintExp or E2:ConstraintExp)
        => constraintExpEval(T1 T2 E1) orBool constraintExpEval(T1 T2 E2)
    
    // rule constraintExpEval(T1:TypeName T2:TypeName (E:ConstraintExp) )
    //     => constraintExpEval(T1 T2 E)
    
    rule constraintExpEval(T1:TypeId T2:TypeId A:Name O:BoolOp B:Name)
        => #if A ==K #token("t1", "Id") orBool A ==K #token("t2", "Id")
            orBool B ==K #token("t1", "Id") orBool B ==K #token("t2", "Id")
        #then
            evalCooledExp(
                {
                    #if A ==K #token("t1", "Id") #then T1 
                    #else #if A ==K #token("t2", "Id") #then T2 
                    #else A #fi #fi
                }:>Id
                O
                {
                    #if B ==K #token("t1", "Id") #then T1 
                    #else #if B ==K #token("t2", "Id") #then T2 
                    #else B #fi #fi
                }:>Id
            )
        #else
            true
        #fi
    
    syntax Bool ::= "evalCooledExp" "(" Id BoolOp Id ")" [function]
    rule evalCooledExp(A:Id == B:Id) => A ==K  B
    rule evalCooledExp(A:Id != B:Id) => A =/=K B

endmodule

module CHECK
    imports CONFIGURATION
    
    syntax Controller ::= "build-labels"
                        | "check1"
                        | "check2"
    
    rule <k> check 
            => build-labels
            ~> check1 
            ~> check2
            ...
        </k>
endmodule


module CHECK-0
    imports CHECK
    imports LIST
    imports COLLECTIONS
    imports K-EQUAL

    syntax Controller ::= "get-rules"
                        | "get-rules-1"
                        | "getAllObjects"
                        | "getAllObjects-1"
                        | "getAllObjects-2"
                        | "getAllDomains"
                        | "getAllDomains-1"
                        | "getAllDomains-2"
                        | "ExtractObjectTypeLabel"
                        | "ExtractObjectTypeLabel-1"
                        | "ExtractObjectTypeLabel-2"
                        | "ExtractDomainLabel"
                        | "ExtractDomainLabel-1"
                        | "ExtractDomainLabel-2"
                        | "ExtractDomainLabel-read"
                        | "ExtractDomainLabel-write"

    rule <k> build-labels
            => get-rules
            ~> getAllObjects
            ~> getAllDomains
            ~> ExtractObjectTypeLabel
            ~> ExtractDomainLabel
            ...
        </k>

    rule <k> get-rules => get-rules-1 ~> Allows ...</k>
        <allow> Allows:Set </allow>
    
    rule <k> get-rules-1 ~> .Set => . ...</k>
    rule <k> get-rules-1
            ~> ( SetItem(allow T1:TypeId T2:TypeId : C:ClassId P:PermId) 
                Allows:Set => Allows )
            ...
        </k>
        <rules>
            L:List => L {
                #if P ==K #token("read","Id") orBool P ==K #token("write","Id")
                #then ListItem(allow T1 T2 : C P)
                #else .List #fi
            }:>List
        </rules>
    
    // get all objects
    rule <k> getAllObjects => getAllObjects-1 ~> 0 ... </k>
        <domains> _ => .Set </domains>
        <objects> _ => .Set </objects>

    rule <k> getAllObjects-1 ~> Index:Int
            => #if Index <Int size(L)
                #then getAllObjects-2 ~> L[Index]
                    ~> getAllObjects-1 ~> Index +Int 1
                #else . #fi
            ...
        </k>
        <rules> L:List </rules>

    rule <k> getAllObjects-2 
            ~> allow _:TypeId T2:TypeId : C:ClassId _:PermId
            => . ...
        </k>
        <objects> S:Set => S SetItem(T2 : C) </objects>


    // get all domains
    rule <k> getAllDomains => getAllDomains-1 ~> 0 ... </k>
    rule <k> getAllDomains-1 ~> Index:Int 
            => #if Index <Int size(L)
                #then getAllDomains-2 ~> L[Index]
                    ~> getAllDomains-1 ~> Index +Int 1
                #else . #fi
            ...
        </k>
        <rules> L:List </rules>
    
    rule <k> getAllDomains-2 
            ~> allow T1:TypeId _:TypeId : _:ClassId _:PermId
            => . ...
        </k>
        <domains> S:Set => S SetItem(T1) </domains>


    // extract object type label
    rule <k> ExtractObjectTypeLabel 
            => ExtractObjectTypeLabel-1 ~> Set2List(S)
            ...
        </k>
        <objects> S:Set </objects>

    rule <k> ExtractObjectTypeLabel-1 ~> ( ListItem(O:Object) L:List => L )
        ...</k>
        <object-type-labels>
            <O-write> M1:Map => M1 [ O <- .Set ] </O-write>
            <O-read>  M2:Map => M2 [ O <- .Set ] </O-read>
        </object-type-labels>
    
    rule <k> ExtractObjectTypeLabel-1 ~> .List
            => ExtractObjectTypeLabel-2 ~> L
            ...
        </k>
        <rules> L:List </rules>

    rule <k> ExtractObjectTypeLabel-2
            ~> ( ListItem(allow T1:TypeId T2:TypeId : C:ClassId #token("read","Id"))
                Rs:List => Rs )
            ...
        </k>
        <O-read>... T2 : C |-> (S:Set => S SetItem(T1)) ...</O-read>
    
    rule <k> ExtractObjectTypeLabel-2
            ~> ( ListItem(allow T1:TypeId T2:TypeId : C:ClassId #token("write","Id"))
                Rs:List => Rs )
            ...
        </k>
        <O-write>... T2 : C |-> (S:Set => S SetItem(T1)) ...</O-write>

    rule <k> ExtractObjectTypeLabel-2
            ~> ( ListItem(neverallow _T1:TypeId _T2:TypeId : _C:ClassId _P:PermId) 
                Rs:List => Rs )
            ...
        </k>
    
    rule <k> ExtractObjectTypeLabel-2 ~> .List => . ...</k>


    // extract domain labels

    rule <k> ExtractDomainLabel => ExtractDomainLabel-1 ~> Set2List(S) ...</k>
        <domains> S:Set </domains>

    rule <k> ExtractDomainLabel-1 ~> ( ListItem(D:TypeId) Ds:List => Ds ) ...</k>
        <domain-labels>
            <D-read>  M1:Map => M2 [ D <- S ] </D-read>
            <D-write> M2:Map => M1 [ D <- S ] </D-write>
        </domain-labels>
        <domains> S:Set </domains>
    
    rule <k> ExtractDomainLabel-1 ~> .List
            => ExtractDomainLabel-2 ~> Set2List(S)
            ...
        </k>
        <objects> S:Set </objects>
    
    rule <k> ExtractDomainLabel-2 ~> ListItem(T:Object) Ts:List
            => ExtractDomainLabel-read ~> T ~> Set2List(Rt)
            ~> ExtractDomainLabel-write ~> T ~> Set2List(Wt)
            ~> ExtractDomainLabel-2 ~> Ts
            ...
        </k>
        <O-read>...  T |-> Rt:Set ...</O-read>
        <O-write>... T |-> Wt:Set ...</O-write>

    rule <k> ExtractDomainLabel-2 ~> .List => . ...</k>

    
    
    rule <k> ExtractDomainLabel-read ~> T:Object 
            ~> ( ListItem(D:TypeId) Ds:List => Ds )
            ...
        </k>
        <O-read>... T |-> Rt:Set ...</O-read>
        <D-read>... D |-> ( S:Set => intersectSet(S, Rt) ) ...</D-read>

    rule <k> ExtractDomainLabel-read ~> _T:Object ~> .List => . ...</k>

    rule <k> ExtractDomainLabel-write ~> T:Object 
            ~> ( ListItem(D:TypeId) Ds:List => Ds )
            ...
        </k>
        <O-write>... T |-> Wt:Set ...</O-write>
        <D-write>... D |-> ( S:Set => intersectSet(S, Wt) ) ...</D-write>
    
    rule <k> ExtractDomainLabel-write ~> _:Object ~> .List => . ...</k>

endmodule


module CHECK-1
    imports CHECK
    imports LIST
    imports COLLECTIONS
    imports K-EQUAL

    syntax Controller ::= "AccessRuleChecks"
                        | "AccessRuleChecks-1"
                        | "AccessRuleChecks-2"
                        | "AccessRuleChecks-2-read"
                        | "AccessRuleChecks-2-write"
                        | "AccessRuleChecks-3"
                        | "AccessRuleChecks-3-read"
                        | "AccessRuleChecks-3-write"
                        | "ConsistencyCheck"
                        | "find-wrong-allow"
                        | "find-wrong-allow-1"

    rule <k> check1
            => AccessRuleChecks
            ~> ConsistencyCheck
            ~> find-wrong-allow
            ...
        </k>

    // access rule checks
    rule <k> AccessRuleChecks => AccessRuleChecks-1 ~> L ...</k>
        <rules> L:List </rules>
        <indirect-rules> _:Set => .Set </indirect-rules>

    // rule <k> AccessRuleChecks-1 
    //         ~> (ListItem(neverallow _:TypeName _:TypeName : _:ClassName _:PermName) Rs:List => Rs)
    //     ...</k>

    rule <k> AccessRuleChecks-1 
            ~> ListItem(allow T1:TypeId T2:TypeId : C:ClassId #token("read","Id")) 
                Rs:List
            => #if Wt <=Set Wd
                #then .K
                #else AccessRuleChecks-2-read ~> T1 ~> Wt -Set Wd
                #fi
            ~> AccessRuleChecks-1 ~> Rs
            ...
        </k>
        <D-write>... T1 |-> Wd:Set ...</D-write>
        <O-write>... T2 : C |-> Wt:Set ...</O-write>
        // requires notBool Wt <=Set Wd

    
    rule <k> AccessRuleChecks-1 
            ~> ListItem(allow T1:TypeId T2:TypeId : C:ClassId #token("write","Id"))
                Rs:List
            => #if Rt <=Set Rd 
                #then .K 
                #else AccessRuleChecks-2-write ~> T1 ~> Wt -Set Wd
                #fi
            ~> AccessRuleChecks-1 ~> Rs
            ...
        </k>
        <D-write>... T1 |-> Wd:Set ...</D-write>
        <D-read> ... T1 |-> Rd:Set ...</D-read>
        <O-write>... T2 : C |-> Wt:Set ...</O-write>
        <O-read> ... T2 : C |-> Rt:Set ...</O-read>
    
    rule <k> AccessRuleChecks-1 ~> .List => . ...</k>


    rule <k> AccessRuleChecks-2-read 
            ~> D:TypeId ~> SetItem(D1:TypeId) Ds:Set
            => AccessRuleChecks-3-read ~> D ~> D1 ~> keys_list(W)
            ~> AccessRuleChecks-2-read ~> D ~> Ds:Set
            ...
        </k>
        <O-write> W:Map </O-write>

    rule <k> AccessRuleChecks-2-write
            ~> D:TypeId ~> SetItem(D1:TypeId) Ds:Set
            => AccessRuleChecks-3-write ~> D ~> D1 ~> keys_list(W)
            ~> AccessRuleChecks-2-write ~> D ~> Ds:Set
            ...
        </k>
        <O-write> W:Map </O-write>
    
    rule <k> AccessRuleChecks-2-read  ~> _D:TypeId ~> .Set => . ...</k>
    rule <k> AccessRuleChecks-2-write ~> _D:TypeId ~> .Set => . ...</k>


    rule <k> AccessRuleChecks-3-read ~> _:TypeId ~> _:TypeId 
            ~> .List => . ...
        </k>
    rule <k> AccessRuleChecks-3-read ~> D:TypeId ~> D1:TypeId 
            ~> ( ListItem(T:TypeId : C:ClassId) Ts:List => Ts )
            ...
        </k>
        <indirect-rules>
            S:Set => (
                #if D in {W[T : C]}:>Set 
                #then SetItem(allow D1 T : C #token("write", "Id")) 
                #else .Set #fi
            ) |Set S
        </indirect-rules>
        <O-write> W:Map </O-write>
    
    rule <k> AccessRuleChecks-3-write ~> _:TypeId ~> _:TypeId
            ~> .List => . ...
        </k>
    rule <k> AccessRuleChecks-3-write ~> D:TypeId ~> D1:TypeId
            ~> ( ListItem(T:TypeId : C:ClassId) Ts:List => Ts )
            ...
        </k>
        <indirect-rules>
            S:Set => (
                #if D in {W[T : C]}:>Set 
                #then SetItem(allow D1 T : C #token("read", "Id")) 
                #else .Set #fi
            ) |Set S
        </indirect-rules>
        <O-write> W:Map </O-write>
    

    // again if there are indirect rules
    rule <k> ConsistencyCheck 
            => #if size(S1) ==Int 0 #then . #else build-labels #fi
            ...
        </k>
        <indirect-rules> S1:Set => .Set </indirect-rules>
        <rules> L:List => Set2List(List2Set(L) |Set S1) </rules>
        <indirect-rules-result>
            S2:Set => S2 |Set S1
        </indirect-rules-result>
    
    rule <k> find-wrong-allow => find-wrong-allow-1 ~> S ...</k>
        <indirect-rules-result> S:Set </indirect-rules-result>

    
    rule <k> find-wrong-allow-1 ~> .Set => . ...</k>

    rule <k> find-wrong-allow-1 
            ~> ( SetItem(allow T1:TypeId T2:TypeId : C:ClassId P:PermId) 
                S:Set => S )
            ...
        </k>
        <wrongallow> 
            S1:Set => {
                #if P in {M[(T1 T2 C)] orDefault .Set}:>Set 
                    |Set {M[(T1 *  C)] orDefault .Set}:>Set
                    |Set {M[(*  T2 C)] orDefault .Set}:>Set
                #then SetItem(allow T1 T2 : C P)
                #else .Set #fi
            }:>Set |Set S1
        </wrongallow>
        <neverallow-map> M:Map </neverallow-map>

endmodule


module CHECK-2
    imports CHECK
    imports COLLECTIONS

    syntax Controller ::= "coverage-1"

    rule <k> check2 => coverage-1 ~> Set2List(S) ... </k>
        <rules> _ => Set2List(S) </rules>
        <allow> S:Set </allow>
        <types> Ts:Set </types>
        <domain-labels>
            <D-read>  _ => .Map </D-read>
            <D-write> _ => .Map </D-write>
        </domain-labels>
        <object-type-labels>
            <O-read>  _ => .Map </O-read>
            <O-write> _ => .Map </O-write>
        </object-type-labels>
        <t1-unused> _ => Ts </t1-unused>
        <t2-unused> _ => Ts </t2-unused>
        // <object-noread>  _ => Ts </object-noread>
        // <object-nowrite> _ => Ts </object-nowrite>
        // <domain-noread>  _ => Ts </domain-noread>
        // <domain-nowrite> _ => Ts </domain-nowrite>

    
    // rule <k> coverage-1
    //         ~> ( ListItem(allow T1:TypeName T2:TypeName : _C:ClassName #token("read","Id"))
    //             Rs:List => Rs )
    //         ...
    //     </k>
    //     <object-noread> S1:Set => S1 -Set SetItem(T2) </object-noread>
    //     <domain-noread> S2:Set => S2 -Set SetItem(T1) </domain-noread>

    // rule <k> coverage-1 
    //         ~> ( ListItem(allow T1:TypeName T2:TypeName : _C:ClassName #token("write","Id"))
    //             Rs:List => Rs )
    //         ...
    //     </k>
    //     <object-nowrite> S1:Set => S1 -Set SetItem(T2) </object-nowrite>
    //     <domain-nowrite> S2:Set => S2 -Set SetItem(T1) </domain-nowrite>
    
    rule <k> coverage-1 
            ~> ( ListItem(allow T1:TypeId T2:TypeId : _:ClassId _:PermId )
                Rs:List => Rs )
            ...
        </k>
        <t1-unused> S1:Set => S1 -Set SetItem(T1) </t1-unused>
        <t2-unused> S2:Set => S2 -Set SetItem(T2) </t2-unused>

    // rule <k> coverage-1 ~> ListItem(neverallow _:TypeName _:TypeName : _:ClassName _:PermName) Rs:List
    //         => coverage-1 ~> Rs
    //     ...</k>

    rule <k> coverage-1 ~> .List => . ... </k>
        <rules> _ => .List </rules>

endmodule
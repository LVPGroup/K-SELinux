requires "syntax.k"
// requires "semantics/utils.k"


module CONFIGURATION
    imports SELINUX-SYNTAX
    imports SET
    imports MAP
    imports LIST
    // imports UTILS
    imports INT
    imports ID

    // syntax Pgm ::= List{Stmt, ""}
    syntax Controller ::= "parse-end"
                        | "check"
                        | "all-end"

    configuration <T>
        <k> $PGM:Pgm ~> parse-end ~> all-end </k>

        // class
        <classes>       .Set </classes>
        <commons>       .Set </commons>
        <common-perms>  .Map </common-perms>
        <class-perms>   .Map </class-perms>

        // type
        <types>      .Set </types>
        <attrs>      .Set </attrs>
        <type-alias> .Map </type-alias>
        <attr-types> .Map </attr-types>

        // sid
        <sids> .Map </sids>
        <caps> .Set </caps>

        // access
        <allow>      .Set </allow>
        // <auditallow> .Map </auditallow>
        // <dontaudit>  .Map </dontaudit>
        // <auditdeny>  .Map </auditdeny>
        <neverallow> .Set </neverallow>
        <neverallow-map> .Map </neverallow-map>
        <wrongallow> .Set </wrongallow>

        // constrain
        <constraints>   .Map </constraints>
        <validatetrans> .Map </validatetrans>
        <constraint-failed> .Set </constraint-failed>

        // role
        <roles>      .Set </roles>
        <users>      .Set </users>
        <attr-roles> .Map </attr-roles>
        <user-roles> .Map </user-roles>
        <role-types> .Map </role-types>
        <roleAllow>  .Map </roleAllow>
        <roleTrans>  .Set </roleTrans>
        <dominance>  .Set </dominance>

        // mls
        <sensitivities>    .Set </sensitivities>
        <sens-alias>       .Map </sens-alias>
        <levels>           .Map </levels>
        <categories>       .Set </categories>
        <dominances>       .Set </dominances>
        <category-alias>   .Map </category-alias>
        <mlsconstrains>    .Map </mlsconstrains>

        // condition
        <bools> .Map </bools>

        // require failed
        <require-failed> .Set </require-failed>

        // to verify
        <class-remained> .Set </class-remained>
        <perm-remained>  .Map </perm-remained>
        <type-remained>  .Set </type-remained>

        <rules> .List </rules>
        <domains> .Set </domains>
        <objects> .Set </objects>
        <domain-labels>
            <D-read>  .Map </D-read>
            <D-write> .Map </D-write>
        </domain-labels>
        <object-type-labels>
            <O-read>  .Map </O-read>
            <O-write> .Map </O-write>
        </object-type-labels>
        // <trusted-type> SetItem(type root:Id ;) </trusted-type>

        // consistency
        <indirect-rules> .Set </indirect-rules>
        <indirect-rules-result> .Set </indirect-rules-result>

        // coverage
        <object-noread>  .Set </object-noread>
        <object-nowrite> .Set </object-nowrite>
        <domain-noread>  .Set </domain-noread>
        <domain-nowrite> .Set </domain-nowrite>
        <t1-unused> .Set </t1-unused>
        <t2-unused> .Set </t2-unused>

        <count>
            <bools-count> 0 </bools-count>
            <classes-count> 0 </classes-count>
            <types-count> 0 </types-count>
            <allows-count> 0 </allows-count>
            <domains-count> 0 </domains-count>
            <objects-count> 0 </objects-count>
            <users-count> 0 </users-count>
            <roles-count> 0 </roles-count>
            <indirect-rule-count> 0 </indirect-rule-count>
        </count>
    </T>

    rule <k> all-end => . ... </k>
        <allow> As:Set => .Set </allow>
        <neverallow-map> _ => .Map </neverallow-map>
        <indirect-rules-result> IRs => .Set </indirect-rules-result>
        <domains> Ds => .Set </domains>
        <objects> Os => .Set </objects>
        <allows-count>  _ => size(As) </allows-count>
        <domains-count> _ => size(Ds) </domains-count>
        <objects-count> _ => size(Os) </objects-count>
        <indirect-rule-count> _ => size(IRs) </indirect-rule-count>

    rule <k> S:Stmt P:Pgm => S ~> P ... </k>

    rule <k> .Pgm => . ... </k>
        <classes>       C => .Set </classes>
        <common-perms>  _ => .Map </common-perms>
        <class-perms>   _ => .Map </class-perms>
        <commons>       _ => .Set </commons>
        <types>         T => .Set </types>
        <attrs>         _ => .Set </attrs>
        <type-alias>    _ => .Map </type-alias>
        <attr-types>    _ => .Map </attr-types>
        <bools>         B => .Map </bools>
        <roles>         R => .Set </roles>
        <users>         U => .Set </users>
        <user-roles>    _ => .Map </user-roles>
        <role-types>    _ => .Map </role-types>
        <roleAllow>     _ => .Map </roleAllow>
        <roleTrans>     _ => .Set </roleTrans>
        <dominance>     _ => .Set </dominance>
        <sids>          _ => .Map </sids>
        <caps>          _ => .Set </caps>
        <categories>    _ => .Set </categories>
        <bools-count> _ => size(keys(B)) </bools-count>
        <classes-count> _ => size(C) </classes-count>
        <types-count>   _ => size(T) </types-count>
        <users-count> _ => size(U) </users-count>
        <roles-count> _ => size(R) </roles-count>

endmodule
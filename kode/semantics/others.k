requires "../configuration.k"

module OTHERS
    imports CONFIGURATION
    imports SET

    rule <k> sid _SN:SidId => . ... </k>
        // <sids> M => M [SN <- .Set] </sids>

    rule <k> sid _SN:SidId _C:Context => . ... </k>
        // <sids> M => M [SN <- SetItem(C) |Set setFromKItem(M[SN] orDefault .Set)] </sids>

    rule <k> policycap _CN:CapId ; => . ... </k>
        // <caps> S => S SetItem(CN) </caps>

    rule <k> _O:OptionalStmt => . ... </k>
    
    // rule <k> RequireStmt => . ...</k>

    rule <k> _:GenfsconStmt   => . ... </k>
    rule <k> _:FsUseTransStmt => . ... </k>
    rule <k> _:FsUseXattrStmt => . ... </k>
    rule <k> _:FsUseTaskStmt  => . ... </k>
    rule <k> _:PortconStmt    => . ... </k>

    rule <k> ; => . ... </k>
endmodule
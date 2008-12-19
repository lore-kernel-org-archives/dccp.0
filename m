From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 19 Dec 2008 05:24:46 +0000
Subject: Re: [RFCv2][PATCH] static builtin CCIDs was Re: [PATCH 2/5] dccp:
Message-Id: <20081219052446.GA3651@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20081217214608.GC14518@ghostprotocols.net>
In-Reply-To: <20081217214608.GC14518@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > | Gerrit, are you OK with this?
| > | 
| > Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
| 
| Applied, thanks everyone.
| 
I am sorry but I have to revert the Acked-by. As per
yesterday's email I was ok with the basic idea, but
already said that this did not include testing.

Please do not apply this patch yet, it introduces several
new problems and needs more work.

1. Module unloading does no longer work - it seems that
   there is an unmatched module_put somewhere.

2. There is an unresolved cyclic dependency with the
   dccp_tfrc_lib module: as soon as CCID-3 is enabled,
   - dccp.ko needs dccp_tfrc_lib.ko to resolve the
     dependencies of CCID-3
   - dccp_tfrc_lib.ko needs dccp.ko since it imports
     symbols of the main DCCP module.
   That is this also prohibits module unloading.

3. A third point why module unloading does not work is
   that there is no ccid_builtins_unregister() function
   called from dccp_fini() in net/dccp/proto.c.

4. This may be Arnaldo's intention, but I disagree wholly
   with it: why do we still have the module loading stuff
   in net/dccp/ccid.c? We currently have no other CCID 
   modules, and this just keeps the flaws of the old
   interface. When I (have to) fix up CCID-4 to work with
   the new interface then I will simply add a new entry 
   into the ccid_builtin_ops. Also -- is the r/w lock that
   was the cause for making this patch really still
   necessary in ccid.c?

5. (May be the cause for point (4)): we now have 3 arrays
   in ccid.c where a single one would fully do:
    
	struct ccid_operations *ccids[CCID_MAX];
	struct ccid_operations *builtin_ccids_ops[]
	u8 builtin_ccids[]

    Why do we keep the duplication between 'ccids' and
    'builtin_ccids_ops' instead of simply saying

      struct ccid_operations *ccids[CCID_MAX] = {
	  /* CCID-2 is supported by default */
	  [DCCPC_CCID2] = &ccid2_ops,	
      #ifdef CONFIG_IP_DCCP_CCID3
	  [DCCPC_CCID3] = &ccid3_ops,	
      #endif
      };

   In this manner we can do away with all the locking
   and loading overhead for non-builtin modules that
   do not even exist. Furthermore, the new routine
   is_builtin_ccid() is then also redundant.

   The second array redundancy is between builtin_ccids[]
   and builtin_ccids_ops[] - one can get the former via
   builtin_ccids_ops[index]->ccid_id.

   That is, I am asking to 
    * use 1 array instead of 3 that each do similar things
    * not make the complicated distinction between builtin
      and non-builtin (which at the moment is the same as
      non-existing)
    * as a result, several routines automatically fall
      under the table, the code becomes much simpler.
    

6. Suggestion: use '__init' annotation for 
   ccids_register_builtins()? (Since almost all routines in
   ccid.c start with ccid_xxx, would it also be more
   consistent to name the routine 'ccid_register_builtins')

7. When fixing the Kconfig dependency for IP_DCCP_TFRC_LIB 
   we need a bool instead of a tristate, e.g.
   
	config IP_DCCP_TFRC_LIB
		bool
		def_bool y if (IP_DCCP_CCID3 = y)

   And then the module_init/exit routines become unnecessary
   in net/dccp/ccids/lib/tfrc.c. When calling their replacement
   from ccid_builtins_register()/unregister() in net/dccp/ccid.c,
   we would need #ifdefs to avoid fusing the code to ccid3.c, e.g.

	int __init ccid_register_builtins(void)
	{
		int i, err;

	#ifdef CONFIG_IP_DCCP_TFRC_LIB
		err = tfrc_lib_init();
		if (err)
			return err;
	#endif
		for ($i = 0; i < ARRAY_SIZE(builtin_ccids_ops); i++) {
			// ...
		}
		return 0;

	unwind_registrations:
	#ifdef CONFIG_IP_DCCP_TFRC_LIB
		tfrc_lib_exit();
	#endif
		// ...
	}

   Linking the tfrc_lib code into ccid3.o seems not to solve the 
   problem since the init()/exit() routines of tfrc_lib are called
   only once instead of for each new socket, as in ccid3.c.

8. The 'extern struct ccid_operations ccid?_ops;' should be in
   ccid.h instead of ccid.c (found via sparse).

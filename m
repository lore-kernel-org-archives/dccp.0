From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 19 Oct 2009 05:21:53 +0000
Subject: Re: [PATCHv2 1/4] First Patch on TFRC-SP. Copy base files from TFRC
Message-Id: <20091019052153.GB3366@gerrit.erg.abdn.ac.uk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="oyUTqETQ0mS9luUI"
List-Id: <dccp.vger.kernel.org>
References: <4AD4B677.4000308@embedded.ufcg.edu.br>
In-Reply-To: <4AD4B677.4000308@embedded.ufcg.edu.br>
To: dccp@vger.kernel.org


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

| First Patch on TFRC-SP.
Please find attached one edit that I made.

I added unwinding the initialisation of tfrc_lib in the case where the
initialisation of tfrc_sp_lib fails.  Unwinding is now done in the reverse
order of the steps done during initialisation.

--oyUTqETQ0mS9luUI
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="1.diff"

--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -223,7 +223,7 @@ int __init ccid_initialize_builtins(void
 
 	err = tfrc_sp_lib_init();
 	if (err)
-		return err;
+		goto unwind_tfrc_lib;
 
 	for (i = 0; i < ARRAY_SIZE(ccids); i++) {
 		err = ccid_activate(ccids[i]);
@@ -235,8 +235,10 @@ int __init ccid_initialize_builtins(void
 unwind_registrations:
 	while(--i >= 0)
 		ccid_deactivate(ccids[i]);
-	tfrc_lib_exit();
+
 	tfrc_sp_lib_exit();
+unwind_tfrc_lib:	
+	tfrc_lib_exit();
 	return err;
 }
 
@@ -246,6 +248,6 @@ void ccid_cleanup_builtins(void)
 
 	for (i = 0; i < ARRAY_SIZE(ccids); i++)
 		ccid_deactivate(ccids[i]);
-	tfrc_lib_exit();
 	tfrc_sp_lib_exit();
+	tfrc_lib_exit();
 }

--oyUTqETQ0mS9luUI--

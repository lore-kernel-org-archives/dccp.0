From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 20 Aug 2008 17:34:04 +0000
Subject: Re: [PATCH] dccp: Reponsed with Reset when packet is received with
Message-Id: <20080820173404.GA3502@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <48AB7147.2010003@cn.fujitsu.com>
In-Reply-To: <48AB7147.2010003@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Thanks a lot for this patch -- I will integrate it into the test tree
and upload the updated version (include Acked-by's) tomorrow morning.

> RFC4340 said that if a packet is received with invalid option(such as Mandatory
> Option as the last byte of the option list),
While looking at dccp_parse_options, it seems to me that this case
(Mandatory as the last option, or a one or more OK-options followed by
 a faulty one) may use the wrong Reset code, since the `rc' variable
is assigned different values while looping through the header options.
Did you notice such a case?

In any case, I will be adding 

--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -243,6 +243,7 @@ ignore_option:
 	}
 
 	/* mandatory was the last byte in option list -> reset connection */
+	rc = DCCP_RESET_CODE_OPTION_ERROR;
 	if (mandatory)
 		goto out_invalid_option;
 
to make sure that previous assignments to `rc' do not override the reset code.

Gerrit

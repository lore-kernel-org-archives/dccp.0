From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 08 Nov 2007 10:35:42 +0000
Subject: Re: [PATCH 23/25] Include ccid-4 to be visible for the DCCP feature negotiation mechanism
Message-Id: <20071108103542.GF11792@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200710312132.06341.leandroal@gmail.com>
In-Reply-To: <200710312132.06341.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| @@ -483,7 +483,8 @@ static u8 dccp_feat_is_valid_sp_val(u8 f
|  {
|  	switch (feat_num) {
|  	case DCCPF_CCID:
| -		return (val = DCCPC_CCID2 || val = DCCPC_CCID3);
| +		return (val = DCCPC_CCID2 || val = DCCPC_CCID3 ||
| +                        val = DCCPC_CCID4);
Whitespace :(blanks instead of tabs, not indented/intended?)


| @@ -787,9 +788,65 @@ static const struct ccid_dependency *dcc
|  			{ 0, 0, 0, 0 }
|  		}
|  	};
| +	static const struct ccid_dependency ccid4_dependencies[2][5] = {
Since the table is the same as for ccid3, you could opt to just use the
ccid3 table to avoid copying, like:

|  	switch (ccid) {
|  	case DCCPC_CCID2: return ccid2_dependencies[is_local];
|  	case DCCPC_CCID3: /* fall through */
| +	case DCCPC_CCID4: return ccid3_dependencies[is_local];
|  	default:	  return NULL;	/* other CCIDs: no specifics yet */
|  	}
|  }

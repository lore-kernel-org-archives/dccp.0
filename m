From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 23 Jun 2008 16:58:26 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies
Message-Id: <20080623165826.GB8692@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > We could still encode the parameters in the policy ID, by splitting the
| > bitmask, e.g. the low 24 bits to encode parameters, and the high 8 bits
| > to encode the policies using the same combination of parameters.
| >
| Yes, technically we could do it this way. Encoding accepted parameters in 
| policy ID would provide applications with means to check whether certain 
| parameters are supported. But should we mix two IMO distinct concepts (policy 
| behaviour and accepted parameters) in one bitfield? I'd rather have them 
| separated.
| 
Yes having them separate gives a clearer semantics. But it comes at a price - 
to retrieve the parameters, we need an extra function or lookup table. 

Maybe there is an elegant solution which allows to encode the required
parameters while keeping the semantics clear?

| Keeping policy IDs as they are and using a bitfield for just parameters could 
| be a nice idea. It would certainly  simplify checking which parameters are 
| supported - just a simple & and = would suffice.
| -- 
And it is fast, too.

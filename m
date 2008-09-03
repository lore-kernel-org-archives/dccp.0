From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Sep 2008 04:51:52 +0000
Subject: Re: [PATCH 09/37] dccp: Resolve dependencies of features on choice
Message-Id: <20080903045152.GF4105@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1219945512-7723-10-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1219945512-7723-10-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > This provides a missing link in the code chain, as several features implicitly
| > depend and/or rely on the choice of CCID. Most notably, this is the Send Ack Vector
| > feature, but also Ack Ratio and Send Loss Event Rate (also taken care of).
| > 
<snip>
| 
| Doesn't this belongs into struct ccid_operations? Why has the core feature
| negotiation have knowledge of any specific CCID? When people want to
| merge CCID 4, 5, etc will we need to change net/dccp/feat.c?
| 
| I think that this needs thus to go to struct ccid_operations, and then the feature
| negotiation code can just use use the ccid number to access:
| 
| struct ccid_operations *ccids[CCID_MAX]
| 
| ccids[ccid_number]->deps
|  
I am answering this again as you raised the point in your answer to Dave.

The above is a sketch, I sat down and thought through how this might
actually be implemented.

For each CCID there are two dependencies - one for the RX and one for
the TX CCID.

Dependency lists are variable-length (CCID-2 has 1/1 and CCID-3 as well as
CCID-4 both have 3/4 for the RX/TX sides).

Using struct ccid_operations to query the CCID dependencies means that 
 * the CCID read lock needs to be taken;
 * protection against failed module-load is needed.

The second point should in principle not be a problem since the feature code
tries to request the modules before the negotiation begins. Implementing this
however would at the very least require to test for failure in these cases.

I don't know whether the fact that one module needs to traverse a memory
region of another module causes issues.

The biggest issue that I see is that there is an indirection now: instead 
of looking up the dependencies directly, one now needs to first go through
struct ccid_operations, from there to individual CCID modules, and then
back to the main dccp.ko module.

What we have here at the moment may not be the last word, but its virtue
is that it is simple, it works, and does not require an indirection via the
CCID sub-unit.

In principle I agree with you, what I am asking for is to defer this code
optimisation until later.

Gerrit

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 04 Sep 2008 00:59:31 +0000
Subject: Re: [PATCH 09/37] dccp: Resolve dependencies of features on choice
Message-Id: <20080904005931.GG12639@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <1219945512-7723-10-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1219945512-7723-10-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Sep 03, 2008 at 06:51:52AM +0200, Gerrit Renker escreveu:
> | > This provides a missing link in the code chain, as several features implicitly
> | > depend and/or rely on the choice of CCID. Most notably, this is the Send Ack Vector
> | > feature, but also Ack Ratio and Send Loss Event Rate (also taken care of).
> | > 
> <snip>
> | 
> | Doesn't this belongs into struct ccid_operations? Why has the core feature
> | negotiation have knowledge of any specific CCID? When people want to
> | merge CCID 4, 5, etc will we need to change net/dccp/feat.c?
> | 
> | I think that this needs thus to go to struct ccid_operations, and then the feature
> | negotiation code can just use use the ccid number to access:
> | 
> | struct ccid_operations *ccids[CCID_MAX]
> | 
> | ccids[ccid_number]->deps

> In principle I agree with you, what I am asking for is to defer this code
> optimisation until later.

Fair enough.

- Arnaldo

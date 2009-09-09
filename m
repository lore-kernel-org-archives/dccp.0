From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 09 Sep 2009 20:19:41 +0000
Subject: Re: [PATCH 0/5] Adds implementation of TFRC-SP on DCCP test tree
Message-Id: <20090909201941.GB5205@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210909011943s656fbadfo95132dc2fba0d73c@mail.gmail.com>
In-Reply-To: <cb00fa210909011943s656fbadfo95132dc2fba0d73c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| These patches adds implementation of TFRC-SP at the receiver side, and
| are targeted at the DCCP branch
<snip> 
| 
| Following this patches, we'll be sending the sender side of TFRC-SP.
| Once this code is integrated on the branch, we can proceed adding the
| CCID4 code that uses this new TFRC-SP.

Thanks for all the work and for resending. I will be going through these
over the weekend. My suggestion is that if they compile and work cleanly,
to replace the existing patches in the CCID-4 subtree, so that testing
of the experimental CCID-4 features can continue.

Thanks a lot
Gerrit

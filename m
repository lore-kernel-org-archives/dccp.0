From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 13 Dec 2007 14:14:43 +0000
Subject: Re: [Announce]: Test results with latest CCID3 patch set
Message-Id: <20071213141443.GA28451@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20071210154008.GA16839@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20071210154008.GA16839@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|     git-clone git://eden-feed.erg.abdn.ac.uk/dccp_exp my_dccp
| 
| 
| But I did not check out the DCCP sub-branch, by:
| 
|     git-checkout --track -b dccp origin/dccp
| 
| 
| However, as I type this command above, git complains saying:
| 
|     git checkout: branch dccp already exists
| 
| 
| It this OK to say so?
The `--track' command is only necessary to instruct git to always pull
from the given remote destination.

Apparently the dccp subtree got cloned as well. If this succeeded, you
can check out the sub branch via "git-checkout dccp" (no -b); check
with "git-branch" on which branch you are on.

I mostly use the other method, i.e. for my work I pull the test tree
after creating a branch master/dccp and then clone:
  git checkout -b dccp master
  git pull git://eden-feed.erg.abdn.ac.uk/dccp_exp dccp
 

Sorry in the previous reply I forgot to mention that there is a much
easier way to doi all this - the entire test tree is available as a
single patch, for most recent releases on
 http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/test-tree/
This can be applied via "zcat test-tree_*.diff.gz| patch -p1 [--dry-run]"

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 07 Jul 2008 15:08:54 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies
Message-Id: <20080707150854.GA30372@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > We were at this point already and agreed not to change parameter <-> qdisc
| > relationship between versions.
| No, we didn't.
| 
It seems we've both lost the thread 8-)

| I still don't get how you wish to add more parameters if there is a need to do 
| so. Adding new policies is an overkill if addition of new parameters just 
| extends existing functionality and does not create something completely new 
| and incompatible.
| 
I have a sketch somewhere for adding new policies without much effort, but I can't
find the file (/tmp cleared). Will dig this out and reply to your email later.

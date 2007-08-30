From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 30 Aug 2007 07:30:44 +0000
Subject: Re: [PATCH 0/6] DCCP: Implement TFRC Faster Restart
Message-Id: <200708300830.44425@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200708291113.07431.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200708291113.07431.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Ian -

|  This patch set implements TFRC Faster Restart as per current draft.
I have created a subtree `dccp_fr' which contains all these patches. It can
be pulled via
 
	git pull git://eden-feed.erg.abdn.ac.uk/dccp_exp dccp_fr

and, since it is a subtree of the main tree, it automatically inherits
it (ie. the branches are arranged dccp --> dccp_fr).

Let me know if you are happy with this. I am flexible regarding how to integrate
the trees (other branch arrangements are possible), but I would like to keep the
code in separate branches for a while:

* when updating to the forthcoming rev04 of the current rev03 of the Faster Restart
  draft, one needs to track the old changes and it is difficult to say now what the
  changes will look like

* there are some internal research comments in the code which help tracking rev03,
  but are specific only to FR implementation

* the CCID3 code is currently facing the following revisions
	- the current code implements rev00
	- Tommi's CCID4 relies on rev01 (not sure about Leandro's)
	- your FR code actually would need rev02
	- rev02 is in the process of being revised and obsoleted into rev03
	
Hope you are ok with this. If there are other/better suggestions, let me know.

Btw: your email client breaks long lines - most of the patches were broken along column 80 or so
     and needed manual fixing.

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 22 Jun 2007 14:23:29 +0000
Subject: [Announce]: How to access Experimental Test Tree
Message-Id: <200706221523.29662@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Mainline kernel development takes a long time, even if changes are small, and
DCCP is in some respects not a finished and fully tested protocol: to enable
testing without the constraints of mainline development, a DCCP test tree
has been set up - with patches taken from this list.

People are encouraged to use this tree and report any findings and make suggestions.

You can pull the entire tree but remember that git kernel sources are in the
order of several hundred megabytes. Here are some suggestions to reduce the
download size - and time.

To pull the entire tree [expensive], use

   git clone git://eden-feed.erg.abdn.ac.uk/dccp_exp.git my_dccp

Much better, if you already have a linux git tree e.g. in /usr/src/linux-2.6, use

   git clone --reference /usr/src/linux-2.6  git://eden-feed.erg.abdn.ac.uk/dccp_exp  my_dccp


Even better: only pull the relevant `dccp' subtree:
---------------------------------------------------
1. The experimental tree is updated every work day from David Miller's tree
   it is a good idea to take an up-to-date copy first:

      git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6

2. chdir into your up-to-date git repository

3. create a subtree `dccp' using the commands
      git checkout -b dccp master

4. pull the experimental DCCP tree into this branch using
      git pull git://eden-feed.erg.abdn.ac.uk/dccp_exp.git dccp


Alternative way:
----------------
1. clone the master branch
      git clone  --reference davem-2.6  git://eden-feed.erg.abdn.ac.uk/dccp_exp

   This will only give you `origin', which is taken from the David Miller tree.

2. Add (all important) the dccp tree:
      git remote  add  dccp  git://eden-feed.erg.abdn.ac.uk/dccp_exp
      git remote  show dccp

3. To track recent changes, do
      git remote  update

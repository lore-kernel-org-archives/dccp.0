From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 04 Dec 2006 13:12:56 +0000
Subject: What happened to the Return of Unload Hack?
Message-Id: <200612041312.56554@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I am now sorting out all experimental patches into a separate directory:

  http://www.erg.abdn.ac.uk/users/gerrit/dccp/experimental_patches/

This is for patches which may be useful in some situations, but not in general
(e.g. the Unload Hack is still an unsafe method and can result in oops if not careful).

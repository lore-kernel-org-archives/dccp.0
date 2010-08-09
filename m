From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 09 Aug 2010 10:54:55 +0000
Subject: [RFD] dccp: Rate Mismatch Controller -- still requires high-res
Message-Id: <20100809105454.GA3591@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I have finished a simple proof-of-concept implementation of the Rate Mismatch Controller for TFRC and put the patches/results on
  
  http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ccid3/sender_notes/rate_mismatch_controller/

The results are not as good as had been hoped - in particular, it still seems
necessary to use high-res timers in order to achieve reasonable stability and
accuracy.

Perhaps I have missed something, but as it stands, I can not see an advantage
in using this for TFRC - comments welcome.

Gerrit

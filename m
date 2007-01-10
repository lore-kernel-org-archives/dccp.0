From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 10 Jan 2007 11:44:38 +0000
Subject: Summary and overview for tackling loss detection / loss history handling
Message-Id: <200701101144.38445@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

In order to clarify some of the discussions on this list, I have done some summaries; essentially
a tidied-up write up of issues that were discussed on this list. 

Loss Detection:
	Currently the CCVal/seqno of packets starting a loss event are out of sync in ccid3_detect_loss,
        which hinders fixing other bugs. I made a case analysis for this on 

        http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/detect_loss_algorithm/detect_loss_notes.txt

        This contains an entire algorithm, for which a flowchart is on 
	http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/detect_loss_algorithm/detect_loss_flowchart.eps
	http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/detect_loss_algorithm/detect_loss_flowchart.png
	http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/detect_loss_algorithm/detect_loss_flowchart.dia


Loss History Handling
	A systematic write-up of points raised earlier on this list is on 
	
	http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/detect_loss_algorithm/summary_of_loss_handling_issues.txt

	This includes a list of currently known bugs which need fixing.


Loss History based on Ring Buffer
	I have worked out a generic algorithm to achieve fixed-size history handling in a LIFO ring buffer.
	The code is deceptively simple, based on a constant HIST_SIZE, and is online on
	
	http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/loss_history_ring-buffer/
	
	The detailed description of how this works is on 
	
	http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/loss_history_ring-buffer/circular_fixed-size_loss-history_buffer.txt


I'd welcome any feedback and comments - if there is none, I may end up sending some of
the documents to the list ;-)

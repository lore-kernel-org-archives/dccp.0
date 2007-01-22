From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 22 Jan 2007 14:24:35 +0000
Subject: CCID 3 bounded by OS scheduling granularity
Message-Id: <200701221424.36105@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I have performed experiments which confirm that

 1) when t_ipi < t_gran, the transmit rate is effectively out of control
 2) when t_ipi > t_gran, the actual transmit rate is about a factor of 3
    higher than s/t_ipi would permit.
    
http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/packet_scheduling/

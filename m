From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 30 Jul 2007 08:34:36 +0000
Subject: RFD: Ack Vectors
Message-Id: <200707300934.36798@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|          * the spec and the code allow to have different CCIDs for forward and return path;
|          * this is foremost a theoretical thing - it is like having e.g. TCP Reno for the data and
|            TCP Hybla for the Acks that come back;
|          * but the practical implementation causes no end of headaches:
|            - With regard to Ian's suggestion, Ack Vectors must be enabled if at least one CCID is CCID2.
|            - If CCID2 talks to CCID3 then CCID2 will want to have its Ack Vectors from the CCID3 peer.
|              However, there is no CCID3 code to support Ack Vectors at the moment (and in the spec this
|              is only implicit).
|            - If CCID3 talks to CCID2 then CCID3 will want its X_recv and loss rate from the CCID2 peer.
|              But how? CCID2 doesn't know these things.
The above is not correct, so please forget it. Furthermore, code which assumes that TX/RX CCID are always
the same is ugly and will sooner or later break, so it is also not an option. 

With regard to the Ack Vectors, my suggestion however is
 * to remove the sysctl - it is confusing;
 * to make the use of Ack Vectors dependent on the current RX CCID;
 * the TX CCID need not be considered for the Ack Vector allocation, since the `Send Ack Vector' 
   feature is server-priority (RFC 4340, 6.4) and thus negotiated by the side which has the RX CCID;
 * optional and for debugging: disabling of Ack Vectors in the Kconfig menu.

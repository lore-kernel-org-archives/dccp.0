From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 22 Feb 2011 11:34:39 +0000
Subject: Re: Proposed NN Feature handling modification
Message-Id: <20110222113439.GF3962@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1297648146.9816.149.camel@jero-laptop>
In-Reply-To: <1297648146.9816.149.camel@jero-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| "values are activated immediately after validation, i.e. we don't wait
|  for the Confirm: either the value is accepted by the peer (and then
|  the waiting is futile), or it is not (Reset or empty Confirm). We
|  don't accept empty Confirms - transmitted values are validated, and
|  the peer "MUST accept any valid value" (RFC 4340, 6.3.2)."
| 
| However, what I have noticed is that this causes a potential problem
| with the Ack Ratio Feature. Specifically, this means that for 1/2 RTT
| the sender thinks each Ack represents a different number of packets than
| the receiver actually means each ack to represent. This is the time
| during which that feature negotiation travels between the sender and the
| receiver.
| 
| In practice, the Appropriate Byte Counting implemented in CCID 2
| prevents any real problem, but a similar situation could crop up with
| other NN options.
| 
| My recommendation is to wait until the Confirm has been received to
| alter the value of an NN feature. This eliminates the problem above and
| has the advantage that it follows RFC 4340 (section 6.6.1). Further,
| making this change should require little code change.
| 
I like the solution introduced in patch #3 because it is simple: Change
options are retransmitted until the correct Confirm option comes in,
instead of resetting the connection. It is an instance of the robustness
principle - the peer can send any outdated/reordered Confirm option.

If this simplicity is not sufficient, it can be extended to cover any cases
where mismatch between endpoints creates temporary problems.

I find it better / more robust to wait for such problems to surface and then
tackle them, rather than making the local state change dependent on the other
end. Doing this complicates processing since the other endpoint is out of local
control, hence we need to make assumptions that can break in practice
(e.g. that a client should reply within two RTTs, but there is a sudden jamming
on the wireless / ADSL, so that the reply comes in only after multiples of
seconds).

Hence I'd very much vote for your approach in patch #3, perhaps with a
debug message in order to track how often a mismatch of (rapidly changing)
options occurs.

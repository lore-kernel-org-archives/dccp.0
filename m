From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Tue, 07 Mar 2006 03:05:51 +0000
Subject: Report: feat negot state
Message-Id: <39e6f6c70603061905i1db54071m6cc2776edd3828bb@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

With the current patch, available at:

http://oops.ghostprotocols.net:81/acme/dccp_minisock.patch

Simple ttcp session transmitting 5 packets:

127.0.0.1.4496 > 127.0.0.1.5001: request  <change_l ack_ratio 2,
change_r ccid 2, change_l ccid 2>
127.0.0.1.5001 > 127.0.0.1.4496: response <change_l ack_ratio 2,
confirm_l ccid 2, confirm_r ccid 2, confirm_r ack_ratio 2>
127.0.0.1.4496 > 127.0.0.1.5001: ack      <nop, confirm_r ack_ratio 2,
ack_vector0 0x00, elapsed_time 108>
127.0.0.1.4496 > 127.0.0.1.5001: dataack  <nop, nop, ack_vector0 0x00,
elapsed_time 16857, ndp_count 1>
127.0.0.1.5001 > 127.0.0.1.4496: ack      <nop, ack_vector0 0x01,
elapsed_time 20>
127.0.0.1.4496 > 127.0.0.1.5001: dataack  <nop, ack_vector0 0x00,
elapsed_time 2495>
127.0.0.1.5001 > 127.0.0.1.4496: ack      <nop, nop, ack_vector0 0x00,
elapsed_time 15, ndp_count 1>
127.0.0.1.4496 > 127.0.0.1.5001: dataack  <nop, ack_vector0 0x00,
elapsed_time 2404>
127.0.0.1.5001 > 127.0.0.1.4496: ack      <nop, nop, ack_vector0 0x00,
elapsed_time 13, ndp_count 2>
127.0.0.1.4496 > 127.0.0.1.5001: dataack  <nop, ack_vector0 0x00,
elapsed_time 2327>
127.0.0.1.5001 > 127.0.0.1.4496: ack      <nop, nop, ack_vector0 0x00,
elapsed_time 14, ndp_count 3>
127.0.0.1.4496 > 127.0.0.1.5001: dataack  <nop, ack_vector0 0x00,
elapsed_time 2077>
127.0.0.1.5001 > 127.0.0.1.4496: ack      <nop, nop, ack_vector0 0x00,
elapsed_time 13, ndp_count 4>
127.0.0.1.4496 > 127.0.0.1.5001: close    <nop, ack_vector0 0x00,
elapsed_time 8425>
127.0.0.1.5001 > 127.0.0.1.4496: reset    <nop, nop, ack_vector0 0x00,
elapsed_time 1121, ndp_count 5>

Still work in progress, requires more testing, but gets feature
negotiation down to
dccp_request_sock level, still need to possibly move more stuff to
dccp_minisock, that
is (or should) be the bare minimum needed to do feature negotiation
when we still don't
have a full blown socket (struct dccp_sock), the previous code is
wrong as we can't use
the listening sock to do feature negotiation at all, so we have to
store the feat negot
state in the minisock that represents the embryonic connection (struct
dccp_request_sock),
and later move this state (in dccp_create_openreq_child) to the newly
inet_csk_cloned
full socket.

And I don't like the many allocations still present, even having
reduced some of the
previous ones I think perhaps we should use a buffer like when we encode the
options in a dccp packet, will try this later.

I'm going to have some sleep now, so this is just for you guys to take
a look at the
current status, more work is needed and the patch has unrelated
changes, will split
when I get satisfied with this stuff.

G'night,

- Arnaldo

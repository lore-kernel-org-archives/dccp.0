From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Date: Wed, 26 Jul 2006 21:48:34 +0000
Subject: dccp: dead code?
Message-Id: <36282A1733C57546BE392885C0618592013E7E2E@chaos.tcs.tcs-sec.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00607261440g5ff3a37buca7642aa20e0435d@mail.gmail.com>
In-Reply-To: <5640c7e00607261440g5ff3a37buca7642aa20e0435d@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi,

I am trying to figure out where/when dccp_v4_reqsk_send_ack and
dccp_v6_reqsk_send_ack
set to request_sock_ops.send_ack are being invoked. Or are these leftover
dead code?

Thanks,

venkat

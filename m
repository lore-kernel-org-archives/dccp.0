From: "Ian McDonald" <imcdnzl@gmail.com>
Date: Thu, 30 Mar 2006 03:13:45 +0000
Subject: Updated version of iperf for DCCP
Message-Id: <cbec11ac0603291913jbb44196xc7e202922c2a3ce6@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi there folks,

I've put an updated version of the DCCP patch for iperf online at:
http://wand.net.nz/~iam4/dccp/dccp-iperf-2.0.2-2.diff

Fixes:
Works again with later kernels. Thanks Andrea for service code fix
Works again with UDP. Thanks Dimitrios for fix
Works with UDP if you use --protocol/-X option
Help is fixed to display protocol help

Can this please be updated on the iperf page?

At some stage I think it would be worth merging some of the changes
upstream but not entirely sure of the procedure. Can somebody clarify?

Thanks,

Ian
--
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand

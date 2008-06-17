From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Tue, 17 Jun 2008 10:42:56 +0000
Subject: QUESTION : Feature length about the non-negotiable feature
Message-Id: <48579530.4010807@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Now non-negotiable feature does not has a fix size, it's length is 
decide by the value of the non-negotiable feature. For example, the 
client send Sequence Window Feature as the following: 0x23 0x04 0x03 
0x64, the Sequence Window Feature has the length of 1-byte only.

But RFC4340 said:

7.5.2.  Sequence Window Feature
   Sequence Window has feature number 3 and is non-negotiable.  It 
takes  48-bit (6-byte) integer values, like DCCP sequence numbers.  
Change  and Confirm options for Sequence Window are therefore 9 bytes long.

Is this correct? Or there are some RFCs said the non-negotiable feature 
has variable length?




require 'spec_helper'

describe Gitlab::Upgrader do
  let(:upgrader) { Gitlab::Upgrader.new }
  let(:current_version) { Gitlab::VERSION }
  let(:popen) { Gitlab::Popen }

  TAGS = <<EOS
38d99e9a05aeec3de09c4a7af2d8af8b34ed5084        refs/tags/v0.9.4
e98c77857f9f765d1854b92c2dc33049504a596d        refs/tags/v0.9.4^{}
4fb7ed46de2ff2d06723e31e87ce55267d84338f        refs/tags/v0.9.5
fa6b5299cdfce0906c996db6b7b35d5644023dc8        refs/tags/v0.9.5^{}
40b27a776111075b9479e315318a49c53aeb44f5        refs/tags/v0.9.6
fd737c54505ee0d0a983047663f73cc5adf0d523        refs/tags/v0.9.6^{}
47bf50f355399c29652c413e4076c9f362186e0f        refs/tags/v1.0.0
f2f456a9e731341ec206c768e22afaadc14d1f8d        refs/tags/v1.0.0^{}
98316f08a8806f01488917ba95896a1962aafa0c        refs/tags/v1.0.1
de5d6e95566d4f9a6b673fcf3f95f84a5f96cb85        refs/tags/v1.0.1^{}
c5ffe354eaa14651d13fd062e81a09638e8ee8bf        refs/tags/v1.0.2
3a2b273316fb29d63b489906f85d9b5329377258        refs/tags/v1.0.2^{}
c14a32b0f3aa3aecca26bb956ea58d9d8d23a511        refs/tags/v1.1.0
baedb24dacac6761f71d9bb732f3e5cdab0c28ca        refs/tags/v1.1.0^{}
74740ee166b400aff27eadf69c6ea8264e560461        refs/tags/v1.1.0pre
35fd988c6ea5aab9c54982059d966799cd6ae2dd        refs/tags/v1.1.0pre^{}
6a7ee4ae8068770177f163ec155ba09d3859acc9        refs/tags/v1.2.0
b56024100d40457a998f83adae3cdc830c997cda        refs/tags/v1.2.0^{}
66c6d431b9465a1b57a10df96a78b7ad94e4f261        refs/tags/v1.2.0pre
86829cae50857b5edf74b935380c6f68a19c2282        refs/tags/v1.2.0pre^{}
1fb9346eecec2fe642359862e07559c61a9ba8be        refs/tags/v1.2.1
7ebba27db21719c0035bab65fea92a4780051c73        refs/tags/v1.2.1^{}
4deac4c52b01e76f31abb9c2e96e878b29965fd9        refs/tags/v1.2.2
139a332293b9d8c4e5436619036e093483d8347f        refs/tags/v1.2.2^{}
1b62d165987dc2a053c8b3ae5152c23d5bf5a1c5        refs/tags/v2.0.0
9a2a8612769d472503b367fa35e99f6fb2876704        refs/tags/v2.0.0^{}
6bf187fe502b62cccac46a4ed70f53f588dd0266        refs/tags/v2.1.0
98d6492582d232ed86525aa31ccbf280f4cbdaef        refs/tags/v2.1.0^{}
83733153f74e5ddefeb16a2563f9652ca75eecdd        refs/tags/v2.2.0
9e6d0710e927aa8ea834b8a9ae9f277be617ac7d        refs/tags/v2.2.0^{}
985804a92fe780a4729e9fdbf92e19496c0af15a        refs/tags/v2.2.0pre
6a445b42003007cbb6c06f477c4d7a0b175688c1        refs/tags/v2.2.0pre^{}
ea2b892a9c3ebe1a85332939e4fdc91d2cf47fec        refs/tags/v2.3.0
b57faf9282d7df6cdd62953d474652a0ae2e6896        refs/tags/v2.3.0^{}
4ea9d27d2af703fd552a4ef74235effc3b9c3839        refs/tags/v2.3.0pre
cadf12c60cc27c5b0b8273c1de4b190a0e88bd7d        refs/tags/v2.3.0pre^{}
9fd8a7d7e5d653d2807656b04d29e10522cff783        refs/tags/v2.3.1
fa8219e0a753e642a6f1dbdfc010d01ae8a949ee        refs/tags/v2.3.1^{}
258c8f932395cd22e3ebfed178d37943e9df9ac3        refs/tags/v2.4.0
204c66461ed519eb0078be7e8ac8a6cb56834753        refs/tags/v2.4.0^{}
626566ee03d5b16bb250ab2c64fdbd66c853348f        refs/tags/v2.4.0pre
1845429268364e75bffdeb1075de8f1606e157ec        refs/tags/v2.4.0pre^{}
432bd54e22ac845bcf28488e349630af8f324f78        refs/tags/v2.4.1
d97a9aa4a44ff9f452144fad348fd9d7e3b48260        refs/tags/v2.4.1^{}
f18339c26d673c5f8b4c19776036fd42a0de30aa        refs/tags/v2.4.2
8c70ac2dd1f4a1f27adde691a055da8cb2bfd1a0        refs/tags/v2.5.0
cc8369144db2147d2956e8dd7d314e9a7dfd4fbb        refs/tags/v2.5.0^{}
1c6763fead01be21c980b759920221ebc89eac16        refs/tags/v2.6.0
b32465712becfbcf83d63b1e6eff7d1483fdabea        refs/tags/v2.6.0^{}
d3d0a7fb90c28d7adfc8027f81354895b5cc88ed        refs/tags/v2.6.0pre
a243253b10244e8a3b62c40b686b52ac61a3adc8        refs/tags/v2.6.0pre^{}
2154c6aa17e110871e78ec4e5853c7a80021487e        refs/tags/v2.6.1
d92a22c9e627268eca697bbd9b660d8c335df953        refs/tags/v2.6.1^{}
98c92318f2bdf8ccef7792566ae0c270b3f09848        refs/tags/v2.6.2
39fecb554f172a0c8ea00316e612e1d37efc7200        refs/tags/v2.6.2^{}
2708bc1f6bad6aaffe5da02bfa2e51cc1ee97953        refs/tags/v2.6.3
666cdb22792dd955a286b9993d6235b4cdd68b4b        refs/tags/v2.6.3^{}
84d4bba447a94fb294d916acc276e86f11e6a433        refs/tags/v2.7.0
8b7e404b5b6944e9c92cc270b2e5d0005781d49d        refs/tags/v2.7.0^{}
ce30b491c906b66be758e1672d3a52eb7a8f7155        refs/tags/v2.7.0pre
72a571724d84d112f98a5543c971e9b3b9da1383        refs/tags/v2.7.0pre^{}
4adbc5c33b3c2cfb89cb0981d782b8e93e710a06        refs/tags/v2.8.0
5c7ed6fa26b47ac71ff6ba04720d85df6d74b200        refs/tags/v2.8.0^{}
8491376af0fbccc4359269c890c943b87ea38908        refs/tags/v2.8.0pre
b2c6ba97a25d299e83c51493d7bc770c13b8ed1a        refs/tags/v2.8.0pre^{}
dd8f1e69962ce7fd9b11a3efa7a127ef292ab7e9        refs/tags/v2.8.1
ed2b53cd1c34c421b23208eeb502a141a6829f9d        refs/tags/v2.8.1^{}
3e67df5fcd7ca3d5fe1b662903bd0a179bc53f6f        refs/tags/v2.8.2
a502f67c0b358cc6b391df0c5dca48375c21fcad        refs/tags/v2.8.2^{}
bbe4e074627bd61ff33818c2b620c25591b59ff8        refs/tags/v2.9.0
4afb7b7cb7b42688bea70298c80b4735f59dab22        refs/tags/v2.9.0^{}
a9409132bc58efb18347a2bc0a20c5017262a726        refs/tags/v2.9.1
a6f58b9c435e1680f102ae68a8aedea981a52486        refs/tags/v2.9.1^{}
c645d3d531909615d69647e8450452d2da5b82b1        refs/tags/v3.0.0
da854542673c9debd4ffa28f1113174e63004857        refs/tags/v3.0.0^{}
1be82f8fe2303a956ff2e2271c0d2cb9dab7249a        refs/tags/v3.0.1
4bc64b5530a45b26a13bf6e71d3b9d41aa1e8f98        refs/tags/v3.0.1^{}
71986d2cdcae0b291f189ea7cf6c5b073b2519b4        refs/tags/v3.0.2
012d62b19828ab1f94ae743c92233f48c714cf8b        refs/tags/v3.0.2^{}
2b86e0659a4abd58374e90a4cd1a227113fdcad7        refs/tags/v3.0.3
5add5f760ebd87e9318f13d3f2ae4e4a4ddbe3ae        refs/tags/v3.0.3^{}
f8f015fa0113dd4dc5dbbde69f6a483d24e6a2dd        refs/tags/v3.1.0
ced242a2d09b65494ae8752b882fa4beed8b58c5        refs/tags/v3.1.0^{}
9a80ed1e8f454670a5904f492f98c7ebaf8a16e2        refs/tags/v4.0.0
6a932d0af511623ab2f9e9e00a28b0cbfd664372        refs/tags/v4.0.0^{}
fc9168155a11c16e9de5e69c49d178ab5612a9e2        refs/tags/v4.0.0rc1
4b649c2f4da31a22aaf658a4a512565e318ab037        refs/tags/v4.0.0rc1^{}
3b8a255aa44dc8c022d1bfd1620c1f315b9b075a        refs/tags/v4.0.0rc2
988e6ac2058881429ced53323e954c2e029de2c9        refs/tags/v4.0.0rc2^{}
28fd793ff15ff99011940fe927380ef3381b71c4        refs/tags/v4.1.0
7014c8782bfabf5bc9fadb34d51a57df999fae1d        refs/tags/v4.1.0^{}
012fb5b214f70175db838777e7c62ab6053151fd        refs/tags/v4.2.0
d67117b5a185cfb15a1d7e749588ff981ffbf779        refs/tags/v4.2.0^{}
5a4a1d5f47ac7143313704bcacc03ff9ed3d5582        refs/tags/v5.0.0
f7ca6c5079bb3c79c709721dae06b77200a1972e        refs/tags/v5.0.0^{}
2cc665299866cf6328b7902105f9f05b20fe3480        refs/tags/v5.0.1
907a8f42a2224dc8ec796717213bf02388c1c364        refs/tags/v5.0.1^{}
136b50e7bc0402ebd3f096e07d31ee2ed7b9d22e        refs/tags/v5.1.0
cbcfe12f58b815db9b9263b36f1576ae389b7276        refs/tags/v5.1.0^{}
672ce6f2220c60cda1b42432f8d85af2de2121f1        refs/tags/v5.2.0
6956c797611500ab731808e849ad4c71a3640c34        refs/tags/v5.2.0^{}
070dd6dc9804265a7a163ecc9a7a1571c2cbadcf        refs/tags/v5.2.1
26ed59f1a53416b2e157cfbf7852663cf0969f5b        refs/tags/v5.2.1^{}
71fcda77199d7536178d89496aa478755e696395        refs/tags/v5.3.0
148eade9d71ee9957633c4a5371857fdb0def605        refs/tags/v5.3.0^{}
94a814d3acd3cb87823adf64aca54d7087c0b2d4        refs/tags/v5.4.0
1944a80c8c09c8f4bc5e94fdd1469ae3d140aa88        refs/tags/v5.4.2
2d65430cd7b2cf3795f922f70ec1b63f12affed6        refs/tags/v5.4.2^{}
5b2a5b56d30396961803a411ea53380b87f673ae        refs/tags/v6.0.0
27e532b42612559e100657026fe8c7510ec7625e        refs/tags/v6.0.0^{}
e753f4f70043fe7e190acdcf778ebc0386d2f438        refs/tags/v6.0.1
4606412d8ed86a9605134ac258431c20d1a71cf0        refs/tags/v6.0.1^{}
87ee40308e7eb3ab9707b66060b6a4758d4eae3c        refs/tags/v6.0.2
dcf9abc1b1550c79c40d744cfac8cc138f204369        refs/tags/v6.1.0
0815967005683260e2c4ba043ed28d984e911541        refs/tags/v6.2.3
675e5203cc00b6b6b5159bc798b593429869aa9b        refs/tags/v6.2.3^{}
7ad3917bb2cc145281f0f1f5abd017287e75686e        refs/tags/v6.2.4
e48313f709e8d99e954a98bc569cfaccd65efa4d        refs/tags/v6.2.4^{}
cf4f36dbf48da84843f45927ab2281887cba6730        refs/tags/v6.3.0
f285da48b1977fd024ba258c9b03d96a77a63d95        refs/tags/v6.3.0^{}
09c6f663e97a4b71268357330401405844b88dc0        refs/tags/v6.3.1
118898745ada5c2a3fd9ebf689f7afe94013b392        refs/tags/v6.4.0
0e4a8e231c19dd2258067fe8a04a69cda305d0ff        refs/tags/v6.4.0^{}
7acd116de0425ec890cfeabd6933ee1ac5730042        refs/tags/v6.4.0.pre1
31892227d7611c1818dbe94b360327e714106297        refs/tags/v6.4.0.pre1^{}
3910acf3bfa8f7422f4304afa9cfd99d4a14731a        refs/tags/v6.4.0.pre2
16916fb103ef0e7f848536a63b57f301e3e08e03        refs/tags/v6.4.0.pre2^{}
d69af9a292e57a8d5ec853d5004fa0c1fe6240f7        refs/tags/v6.4.1
6bc3b5dfa12ef28c2f11ebe003e45b2a051ae2b5        refs/tags/v6.4.1^{}
18cebd2fcdee36b870f6418e70e4aed546ea8335        refs/tags/v6.4.2
214a013bb2395883ae04e819ca703f839b1f63c4        refs/tags/v6.4.2^{}
97e9fe2a92703348d34a8bb9259bfb3f19ec9ae1        refs/tags/v6.4.3
42131d0189bbc0e88be72e6a76405140cbd79fc8        refs/tags/v6.4.3^{}
d88202bef1042acb473ac8110dc7e7881c7f70cd        refs/tags/v6.5.0
51f06bad0b3292226269ada45d6e6994182b6b7b        refs/tags/v6.5.0^{}
3c0a6105d7ec2a54628478bcf3867ad1ec3ebe19        refs/tags/v6.5.0.rc1
e44186209e4fc5015639e18dd10a1991cd852401        refs/tags/v6.5.0.rc1^{}
e70a983171b2f6b7c31fb25cbc57f929d5d02767        refs/tags/v6.5.1
6f6f1588ba5123f156ee3b0635a061745b71fcde        refs/tags/v6.5.1^{}
4835d60fb19ff75379781e7360e8ccd2a4620481        refs/tags/v6.6.0
490f99d45e0f610e88505ff0fb2dc83a557e22c5        refs/tags/v6.6.0^{}
04586391e0f9aecdfb29fef3feabc8a405540022        refs/tags/v6.6.0.pre1
fe6c534d473cef068a0a88d1a5cda9a7dd305e06        refs/tags/v6.6.0.pre1^{}
f90e66cfc3b03896f3996916aacf929a822bbe6b        refs/tags/v6.6.0.rc1
499a118590e875596974e522aecf61bdc05fe0f2        refs/tags/v6.6.0.rc1^{}
c3f794bc62fe73e0a473938f5f460b9773d8bbf0        refs/tags/v6.6.1
49464515982bdef46124f1b3939479aa28e7fe80        refs/tags/v6.6.1^{}
1a6da8eecaf690837e9f74d49b07e99b25252eba        refs/tags/v6.6.2
4ef836923a85d470508f3bdd6b4f30cac2333086        refs/tags/v6.6.2^{}
dd4f57b01681f5d671c1bbbda36e44eb05396c53        refs/tags/v6.6.3
7a21e469160c6464e3b76c3b6682c69c6374b767        refs/tags/v6.6.3^{}
63b027ad5047eb61d68f3900eb9ac32d830dd3f5        refs/tags/v6.6.4
42e34aec97818981338401a47560cd40c05e686d        refs/tags/v6.6.4^{}
4c1e86071d2416547e80f5e3a5a2d04a2ef94914        refs/tags/v6.6.5
8f48f386839816c79e6ad8b023d6ccbabc3d974a        refs/tags/v6.6.5^{}
80236d6c6c763651f398ec4f6b43591b745e385b        refs/tags/v6.7.0
5ec742301c1aa604b9a74430f681da88fff897ad        refs/tags/v6.7.0.rc1
189f88de5b6a85d1bae43cc4625e5d6604bbe6a8        refs/tags/v6.7.0.rc1^{}
dacd5603979bc94256bddfb8e9e20eb57fc31137        refs/tags/v6.7.1
ba0d8842f5398f83be3083f9e277c44a74fd7f58        refs/tags/v6.7.1^{}
c1b19602a90450fe97ccd80a8cc4876fcd9126ac        refs/tags/v6.7.2
dbbf4ea24c7bed7f1eddcfcbfebb3593bc30e92d        refs/tags/v6.7.2^{}
ac11324c12cb684176e58e199631994358b80a1b        refs/tags/v6.7.3
f88d30fac86b317248dbb47e01b050d9c1edbadf        refs/tags/v6.7.3^{}
d0cd56de9c0254939a979266f2bcc53d3b486392        refs/tags/v6.7.4
2f5b6e137eb5ba027f8bef5f720323e8d9fea5ce        refs/tags/v6.7.4^{}
5300b0936530bf2a948ef4fac9cd32afb761b58d        refs/tags/v6.7.5
00aa5c16ee6b06dabb5cd63349942f70bb131dda        refs/tags/v6.7.5^{}
a10e9b7e64a08b933003651db933466d06e2904f        refs/tags/v6.8.0
241132b6ebde69556bf1246ba6fd2a96e51815c3        refs/tags/v6.8.0^{}
7011a8883d907b19d160e88014c92a648cd41721        refs/tags/v6.8.0.rc1
e6b668ab0169f981a5c4162cd8625daf02e6f5a8        refs/tags/v6.8.0.rc1^{}
49d0102ab221c4d9c382febada2884c6e7697206        refs/tags/v6.8.1
319799073b502392fec9e45d617f566a90bef81e        refs/tags/v6.8.1^{}
22538a5182bde9b0079d7c5ab3dc1f9c98760367        refs/tags/v6.8.2
bfdcbc5380119b82bfbe1927c7daf2ae1d53fe19        refs/tags/v6.8.2^{}
f4b20c2a46673eab4b5bbd62c9bd4a65a00c1128        refs/tags/v6.9.0
f0a32c69494a1d4dda4c5ec8a7f3b94bc7ceed65        refs/tags/v6.9.0^{}
a8a1644e0bc3148f0ba0b5f6c8eab9ed7649d96b        refs/tags/v6.9.0.rc1
aacd43d72dcb6d36834a055df52c283a6ce2ffa7        refs/tags/v6.9.0.rc1^{}
79b16ce93ceb0814f147ecb552d8d30c836484de        refs/tags/v6.9.1
13202d828bb4ecf13396961ec39e7f29d86b9ba5        refs/tags/v6.9.1^{}
f9017afe68c03148b4b917c3ff953584a6d4e3d5        refs/tags/v6.9.2
e46b644a8857a53ed3f6c3f64b224bb74b06fd8e        refs/tags/v6.9.2^{}
16ffdb0b1387215ffb7f53652ccf9c77ea2ddaa3        refs/tags/v7.0.0
d1e424bd5c403d73d399bf0f92e39aefde56e638        refs/tags/v7.0.0^{}
1c8fcde1a354b23edf381e7f111810ebcdb086a7        refs/tags/v7.0.0.rc1
70ed6ef2a6894042c9bbd92f273542bca2a2374f        refs/tags/v7.0.0.rc1^{}
7ceae096bfe5e81d3128be61bbf48c671302c07e        refs/tags/v7.1.0
68a9203bcef1e44bdf72acf4cc8d4977eec79b7a        refs/tags/v7.1.0^{}
26a82f744c6c61b8c723d1313c3a2a344cf14c25        refs/tags/v7.1.0.rc1
b634d2801e6abdd039447f53ec5d9cf709f66b06        refs/tags/v7.1.0.rc1^{}
6f0733310546402c15d3ae6128a95052f6c8ea96        refs/tags/v7.1.1
facfec4b242ce151af224e20715d58e628aa5e74        refs/tags/v7.1.1^{}
4ec19d22719ff334bd02c99dc2ba6155eef84fc8        refs/tags/v7.2.0
da5d33e13ec51006edfffd9e286b0f33781a4c12        refs/tags/v7.2.0^{}
e4af150da6e2876bbd6f88ecce17ada6a00f0e73        refs/tags/v7.2.0.rc1
4142754c7f1dda713519b62df76cbc03c9e299c1        refs/tags/v7.2.0.rc1^{}
d3e39cd031a3d2d2e98a595857418f3e9645ade3        refs/tags/v7.2.0.rc2
ed9e922dd0047435b8d349f0c949ba0a2d789247        refs/tags/v7.2.0.rc2^{}
2cdae2965716698fd2d211795af9f05c0063b2a3        refs/tags/v7.2.0.rc3
1eaa8e18be417c9e9b37a56aa5a3f89f4352d352        refs/tags/v7.2.0.rc3^{}
0264ce8bf53e421dc4ffbc33a10be4798af2d8b5        refs/tags/v7.2.0.rc4
f5b23bc2caa8ece27abe4278f6a1b779442f85b4        refs/tags/v7.2.0.rc4^{}
d8eaf19567160c213915cd6a5d1f760fc6b14475        refs/tags/v7.2.0.rc5
87efd92d8cc378697359012226d2679cab7e1e9e        refs/tags/v7.2.0.rc5^{}
8c25c6848452c868ffe0135beaddddd3fa12d4f4        refs/tags/v7.2.1
ff1633f418c29bd613d571107df43396e27b522e        refs/tags/v7.2.1^{}
4ce9757e62e5d936fab1b5ef2173e2453a257288        refs/tags/v7.2.2
3a4ad05c463ce951eadc0c2c293e9f6524a04f57        refs/tags/v7.2.2^{}
bd567cce1f2e9ba19ab0773b7a43c2097d651be9        refs/tags/v7.3.0
a04f0e5b3dece759bc82d89d32a4cadb67e6bb71        refs/tags/v7.3.0^{}
c786822a9c8ae6798c16b5174baf412cb896a021        refs/tags/v7.3.0.rc1
630d042433e0cecffe80aa5ebd7aa7a91c5eb2d8        refs/tags/v7.3.0.rc1^{}
40a0f16f9906dcf93adc17a18cbfabd0e173f290        refs/tags/v7.3.1
1660aa23e3f6bea8e0de54a420e29953f6bd194f        refs/tags/v7.3.1^{}
EOS

  describe 'current_version_raw' do
    it { upgrader.current_version_raw.should == current_version }
  end

  describe 'latest_version?' do
    it 'should be true if newest version' do
      upgrader.stub(latest_version_raw: current_version)
      upgrader.latest_version?.should be_true
    end
  end

  describe 'latest_version_raw' do
    it 'should be latest version for GitLab 5' do
      upgrader.stub(current_version_raw: "5.3.0")
      popen.stub(popen: TAGS)
      upgrader.latest_version_raw.should == "v5.4.2"
    end
  end
end

B3 Experiment: An Experiment of System Electronics
==================================================

B3の後期実験、「システムエレクトロニクス実験プロジェクト」の課題で作ったものを公開してみました。  
使ったFPGAはVirtex5シリーズのどれかだったと思うのですが、型番は忘れてしまいました。

制作物
------
* __IQ mapper/demapper__  
  (rtl/comm/iqmap_*.v iqdemap_*.v)  
  ビット列とbpsk/qpsk/16qamとを相互に変換するモジュール。  
* __FFT IFFT__  
  (rtl/comm/fft64.v ifft64.v)  
  (rtl/comm/radix4_add.v radix4_mul.v)  
  IQマッピングされた入力に対してFFTした出力を返すモジュール。  
  Radix4を用い、パイプライン化を行いました。  
* __Conv, Viterbi__  
  (rtl/comm/conv.v viterbi.v)  
  畳込み(convolution)符号化と、viterbiのアルゴリズムによる復号化するモジュール。  
  これによりBER(Bit Error Rate)が改善するはずでしたが、これらを利用する際に入出力のインターフェースの仕様がきちんと把握できていなかったために時間に間に合いませんでした。  
* __sim.sh__  
  (rtl/comm/sim.sh)  
  Xilinxのfuseとかisimとかを使うのが手間だったので書いたスクリプト。  


// [[Rcpp::depends(RcppArmadillo)]]
#include <RcppArmadillo.h>
#include <Rcpp.h>
using namespace Rcpp;

//' @name calcDistance
//' @title Compute mop distance
//' @param A is the reference matrix.
//' @param B is the transfer matrix.
//' @return Returns a vector of mop values
// [[Rcpp::plugins(unwindProtect)]]
// [[Rcpp::export]]
 double calcDistance(const arma::mat &A, const arma::mat &B) {
   //return std::sqrt(arma::accu(arma::square(A - B)));
   return arma::accu(arma::square(A - B));

 }

double arma_mean(const arma::vec &A){
  return arma::mean(A);
}

//' @name calcMOP
//' @title Compute mop serial version
//' @param x is the reference matrix.
//' @param y is the transfer matrix.
//' @return Returns a vector of mop values

// [[Rcpp::plugins(unwindProtect)]]
// [[Rcpp::export]]
arma::vec calcMOP (arma::mat &x, arma::mat &y, arma::vec &prob){

  int n_rowx = x.n_rows;
  int n_rowy = y.n_rows;
  arma::vec output1(n_rowx);
  arma::vec output2(n_rowy);

  for(int i=0; i< n_rowy; ++i){
    arma::mat A = y.row(i);
    for(int j=0; j< n_rowx; ++j){
      arma::mat B = x.row(j);
      double a = calcDistance(A,B);
      output1[j] = a;
    }
    arma::vec outq = arma::quantile(output1,prob);
    output2[i] = arma_mean(outq);
    }
  return output2;
}

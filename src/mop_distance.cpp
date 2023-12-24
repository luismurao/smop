// [[Rcpp::depends(RcppArmadillo)]]
#include <RcppArmadillo.h>
#include <Rcpp.h>
using namespace Rcpp;


double rcpp_mean(NumericVector x) {
  double total = 0;
  for(NumericVector::iterator i = x.begin(); i != x.end(); ++i) {
    total += *i;
  }
  return total/x.length();
}

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

 };

double arma_mean(const arma::vec &A){
  return arma::mean(A);
}


Rcpp::NumericVector lq(Rcpp::NumericVector x, double th) {
  return x[x <= th];
};


double quantile(Rcpp::NumericVector &x,double prob){
  double index = 1 + (x.length() -1)*prob;
  int lo = floor(index);
  //int hi = ceil(index);
  x = x.sort();
  double qs = x.at(lo);
  return qs;
};



//' @name Quantile
//' @title Helper function to estimate the quantile of a sample distribution
//' Returns a vector of the x values less or equal to the selected quantile
//' @details The function is taken from
//' https://github.com/RcppCore/Rcpp/issues/967
//' The authors are Rodney Sparapani and Dirk Eddelbuettel

 Rcpp::NumericVector Quantile(Rcpp::NumericVector x, Rcpp::NumericVector probs) {
   // implementation of type 7
   unsigned n=x.size(), np=probs.size();
   if (n==0) return x;
   if (np==0) return probs;
   Rcpp::NumericVector index = (n-1.)*probs, y=x.sort(), x_hi(np), qs(np);
   Rcpp::NumericVector lo = Rcpp::floor(index), hi = Rcpp::ceil(index);

   for (size_t i=0; i<np; ++i) {
     qs[i] = y[lo[i]];
     x_hi[i] = y[hi[i]];
     if ((index[i]>lo[i]) && (x_hi[i] != qs[i])) {
       double h;
       h = index[i]-lo[i];
       qs[i] = (1.-h)*qs[i] + h*x_hi[i];
     }
   }
   return x[x<=qs[0]];
 };

NumericVector Cquantile(NumericVector x, NumericVector q) {
  NumericVector y = clone(x);
  std::sort(y.begin(), y.end());
  return y[x.size()*(q - 0.000000001)];
};



//' @name calcMOP
//' @title Compute mop serial version
//' @param x is the reference matrix.
//' @param y is the trasfer matrix.
//' @return Returns a vector of mop values
//' @details The unique difference with the function parcalcMOP
//' is that it prints the percentage of advance

// [[Rcpp::plugins(unwindProtect)]]
// [[Rcpp::export]]

 Rcpp::NumericVector calcMOP (arma::mat &x, arma::mat &y, Rcpp::NumericVector prob){

   int n_rowx = x.n_rows;
   int n_rowy = y.n_rows;
   //double n_rowyb = n_rowy;
   //unsigned total = n_rowx*n_rowy;
   //Rcpp::Rcout << "The total number of cells to compare is " <<  total << std::endl;
   //double porcentaje = ceil(n_rowyb / 100.0) ;
   Rcpp::NumericVector output1(n_rowx);
   Rcpp::NumericVector output2(n_rowy);

   for(int i=0; i< n_rowy; ++i){
     arma::mat A = y.row(i);
     for(int j=0; j< n_rowx; ++j){
       arma::mat B = x.row(j);
       double a = calcDistance(A,B);
       output1[j] = a;
     }
     //double q = quantile(output1,prob);
     //Rcpp::NumericVector outq = Quantile(output1,prob);
     //Rcpp::NumericVector outq = Cquantile(output1,prob);
     arma::vec o1 = output1;
     arma::vec p1 = prob;
     Rcpp::NumericVector outq = as<NumericVector>(wrap(arma::quantile(o1,p1)));

     //output2[i] = Rcpp::mean(outq);
     //output2[i] = rcpp_mean(outq);
     output2[i] = arma_mean(outq);
     //if(i % porcentaje ==0)
      // Rcpp::Rcout << "Percentage: " << (i/n_rowyb)*100 << "%" << std::endl;

   };
   return output2;

 };



//
//  ViewController.m
//  Assesment
//
//  Created by Farid Hamid on 3/1/16.
//  Copyright © 2016 ABC. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import "DetailViewController.h"
#import "MBProgressHUD.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,weak) IBOutlet UITextField *textField;
@property (nonatomic,weak) IBOutlet UIButton *searchButton;
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSString *shortForm;
@property (nonatomic,strong) MBProgressHUD *hud;

@property (nonatomic,strong) NSDictionary *dataDictionary;

- (IBAction)searchAction:(id)sender;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    /*
     MBProgressHUD and AFNetworking 2.0 were directly added to the project, typically this would not be the case in production, as any third party frameworks would be added via cocoapods, files were added directly to the project for the sake of the demo.
     */
    self.navigationItem.title = @"Acronym Search";
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataDictionary?((NSArray*)self.dataDictionary[@"lfs"]).count:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier =@"cell";
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.numberOfLines = 0;
    
    NSDictionary *rowDictionary = (NSDictionary*)((NSArray*)self.dataDictionary[@"lfs"])[indexPath.row];
    
    
    NSString *constructString = [NSString stringWithFormat:@"Longform: %@\nFrequency: %@\nSince: %@\nVariations %lu",rowDictionary[@"lf"],rowDictionary[@"freq"],rowDictionary[@"since"],(unsigned long)((NSArray*)rowDictionary[@"vars"]).count];
    
    cell.textLabel.text = constructString;
    
    return cell;
    
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return self.dataDictionary?(NSString*)self.dataDictionary[@"sf"]:0;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *rowDictionary = (NSDictionary*)((NSArray*)self.dataDictionary[@"lfs"])[indexPath.row];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailViewController *vc = (DetailViewController*)[sb instantiateViewControllerWithIdentifier:@"detailViewController"];
    vc.dataArray = ((NSArray*)rowDictionary[@"vars"]);
    vc.longForm = rowDictionary[@"lf"];
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nc animated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)searchAction:(id)sender{
    [self.view endEditing:YES];
    if (![self.textField.text isEqualToString:@""]) {
        self.shortForm = [self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        [self _fetchData];
    }else{
        [self _showAlertWithMessage:@"Empty string, Please enter an acronym"];
    }
}
- (void)_showHudDisplayWithMessage:(NSString*)msg{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.dimBackground = YES;
    self.hud.label.text = msg;
}
- (void)_hideHudDisplay{
    [self.hud hideAnimated:YES];
    
}

- (void)_showAlertWithMessage:(NSString*)msg{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Error"
                                  message:msg
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:@"Ok"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   
                               }];
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)_fetchData{

    NSString *requestString = [NSString stringWithFormat:@"http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=%@", self.shortForm];
    NSURL *URL = [NSURL URLWithString:requestString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
     op.responseSerializer = [AFHTTPResponseSerializer serializer];
    __weak __typeof__(self) weakSelf = self;
    [self _showHudDisplayWithMessage:@"Searching..."];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        
        NSLog(@"%@",dataArray);
        
        if (dataArray && dataArray.count > 0) {
            weakSelf.dataDictionary = dataArray[0];
            [weakSelf.tableView reloadData];
            [weakSelf _hideHudDisplay];
        }else{
            [weakSelf _hideHudDisplay];
            [weakSelf _showAlertWithMessage:@"Acronym not found"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [weakSelf _hideHudDisplay];
        [weakSelf _showAlertWithMessage:[NSString stringWithFormat:@"Network issue: %@",error.description]];
    }];
    [[NSOperationQueue mainQueue] addOperation:op];

}
@end

//
//  DetailViewController.m
//  Assesment
//
//  Created by Farid Hamid on 3/2/16.
//  Copyright © 2016 ABC. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,weak) IBOutlet UITableView *tableView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Variations";
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissModalView)];
}
- (void)dismissModalView{
     [self dismissViewControllerAnimated:YES completion:nil];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray?self.dataArray.count:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier =@"detailCell";
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.numberOfLines = 0;
    
    NSDictionary *rowDictionary = (NSDictionary*)((NSArray*)self.dataArray[indexPath.row]);
    
    
    NSString *constructString = [NSString stringWithFormat:@"Longform: %@\nFrequency: %@\nSince: %@",rowDictionary[@"lf"],rowDictionary[@"freq"],rowDictionary[@"since"]];
    
    cell.textLabel.text = constructString;
    
    return cell;
    
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return self.longForm?self.longForm:@"";
}

@end
